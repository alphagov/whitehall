# frozen_string_literal: true

# DEPENDENT ON having a full production database replicated locally.
# Run with:
#   govuk-docker-run bin/rails runner script/benchmark_edition_search.rb
#
# Environment variables:
#   BENCH_STATE      edition state to filter on (default "active")
#   BENCH_USER_EMAIL user to authorise as (default: the first enabled user)
#   BENCH_RUNS       measured runs per case (default 3)
#   BENCH_SQL=1      also print the slowest query of each case
#   BENCH_EXPLAIN=1  also print EXPLAIN ANALYZE for each case

require "benchmark"
$stdout.sync = true

module EditionFilterBench
module_function

  SCENARIOS = [
    { name: "no title", term: nil },
    { name: "path fragment", term: "/guidance" },
    { name: "two word phrase", term: "consultation outcome" },
    { name: "short term", term: "UK" },
    { name: "single word", term: "nhs" },
    { name: "rare substring", term: "evisa" },
    { name: "exact slug", term: "forthcoming-publications" },
    { name: "mixed case slug", term: "UK-gov" },
    { name: "url, known slug", term: "https://www.gov.uk/government/publications/youth-custody-data" },
    { name: "url, not found", term: "https://www.gov.uk/personal-tax-account" },
  ].freeze

  HEADERS = ["case", "term", "eager", "matches", "queries", "page ms", "count ms", "rows ms", "total ms"].freeze

  WARMUPS = 1
  RUNS = Integer(ENV.fetch("BENCH_RUNS", 3))
  STATE = ENV.fetch("BENCH_STATE", "active")
  PER_PAGE = Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE

  def run!
    user = benchmark_user

    puts "editions:  #{delimited(Edition.count)}"
    puts "state:     #{STATE}"
    puts "per page:  #{PER_PAGE}"
    puts "runs:      #{RUNS} (after #{WARMUPS} warmup)"
    puts "user:      #{user.email} (gds_admin: #{user.gds_admin?}, gds_editor: #{user.gds_editor?})"

    results = SCENARIOS.map { |scenario| measure(user:, scenario:) }

    print_table(results)
    print_slowest_queries(results) if ENV["BENCH_SQL"] == "1"
    print_explains(user:) if ENV["BENCH_EXPLAIN"] == "1"
  end

  def measure(user:, scenario:)
    WARMUPS.times { sample(user:, term: scenario[:term]) }
    samples = Array.new(RUNS) { sample(user:, term: scenario[:term]) }

    samples.first.merge(
      name: scenario[:name],
      term: scenario[:term],
      page_ms: median(samples, :page_ms),
      count_ms: median(samples, :count_ms),
      rows_ms: median(samples, :rows_ms),
      total_ms: median(samples, :total_ms),
    )
  end

  def sample(user:, term:)
    page_scope = scope(user:, term:)
    count_scope = scope(user:, term:)

    measured, queries = capture_queries do
      ActiveRecord::Base.uncached do
        page, page_ms = timed { page_scope.to_a }
        matches, count_ms = timed { count_scope.total_count }
        _rows, rows_ms = timed { touch_rows(page, user) }

        { matches:, page_ms:, count_ms:, rows_ms:, total_ms: page_ms + count_ms + rows_ms }
      end
    end

    measured.merge(
      eager_loading: page_scope.eager_loading?,
      queries: queries.size,
      slowest_query: queries.max_by { |query| query[:ms] },
    )
  end

  def touch_rows(editions, user)
    editions.each do |edition|
      edition.document.content_id
      edition.last_author&.name
      edition.unpublishing
      edition.link_check_report
      edition.access_limited?
      Whitehall::Authority::Enforcer.new(user, edition).can?(:see)
    end
  end

  def scope(user:, term:)
    build_filter(user:, term:).send(:editions_with_translations).page(1).per(PER_PAGE)
  end

  def build_filter(user:, term:)
    options = {
      state: STATE,
      include_unpublishing: true,
      include_link_check_report: true,
      include_last_author: true,
      per_page: PER_PAGE,
    }
    options[:title] = term if term.present?

    Admin::EditionFilter.new(Edition, user, options)
  end

  def capture_queries
    collected = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |event|
      next if event.payload[:name] == "SCHEMA" || event.payload[:cached]

      collected << { sql: event.payload[:sql], ms: event.duration }
    end

    [yield, collected]
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  def print_table(results)
    rows = results.map do |result|
      [
        result[:name],
        truncate(result[:term].nil? ? "-" : result[:term]),
        result[:eager_loading] ? "yes" : "no",
        delimited(result[:matches]),
        result[:queries].to_s,
        sprintf("%.1f", result[:page_ms]),
        sprintf("%.1f", result[:count_ms]),
        sprintf("%.1f", result[:rows_ms]),
        sprintf("%.1f", result[:total_ms]),
      ]
    end

    widths = HEADERS.each_with_index.map do |header, column|
      ([header] + rows.map { |row| row[column] }).map(&:length).max
    end

    puts
    puts table_row(HEADERS, widths)
    puts widths.map { |width| "-" * width }.join("  ")
    rows.each { |row| puts table_row(row, widths) }
  end

  def table_row(cells, widths)
    cells.each_with_index
         .map { |cell, column| column.zero? ? cell.ljust(widths[column]) : cell.rjust(widths[column]) }
         .join("  ")
  end

  def print_slowest_queries(results)
    results.each do |result|
      next if result[:slowest_query].nil?

      puts
      puts "=== slowest query: #{result[:name]} (#{result[:term].inspect}) ==="
      puts sprintf("%.1f ms", result[:slowest_query][:ms])
      puts result[:slowest_query][:sql]
    end
  end

  def print_explains(user:)
    SCENARIOS.each do |scenario|
      explained = scope(user:, term: scenario[:term])

      puts
      puts "=== explain: #{scenario[:name]} (#{scenario[:term].inspect}) ==="
      puts "eager loading: #{explained.eager_loading?}"
      begin
        puts explained.explain(:analyze)
      rescue StandardError => e
        puts "EXPLAIN ANALYZE unavailable (#{e.class}), falling back to EXPLAIN"
        puts explained.explain
      end
    end
  end

  def timed
    value = nil
    elapsed = Benchmark.realtime { value = yield }
    [value, elapsed * 1000.0]
  end

  def median(samples, key)
    values = samples.map { |measurement| measurement[key] }.sort
    values[values.size / 2]
  end

  def truncate(term, length: 30)
    term.length > length ? "…#{term[-(length - 1)..]}" : term
  end

  def delimited(number)
    ActiveSupport::NumberHelper.number_to_delimited(number)
  end

  def benchmark_user
    email = ENV["BENCH_USER_EMAIL"]
    return User.find_by!(email:) if email

    User.enabled.first || raise("No users found")
  end
end

EditionFilterBench.run!
