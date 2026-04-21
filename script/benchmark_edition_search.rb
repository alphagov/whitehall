# frozen_string_literal: true

# DEPENDENT ON having a full production database replicated locally.
# Run with:
#   govuk-docker-run bin/rails runner script/benchmark_edition_search.rb

require "benchmark"
$stdout.sync = true

module EditionFilterBench
module_function

  CASES = [
    { name: "no title filter", term: nil },
    { name: "exact slug", term: "windrush-scheme-application-form-uk" },
    { name: "fuzzy title", term: "Windrush Scheme application form (UK)" },
    { name: "many matches", term: "NHS" },
  ].freeze

  WARMUPS = 3
  RUNS = 10

  def run!
    user = benchmark_user
    edition_count = Edition.count

    CASES.each do |kase|
      term = kase[:term]

      puts
      if term.present?
        puts %(Searching #{edition_count} editions for "#{term}"...)
      else
        puts "Searching #{edition_count} editions with no title filter..."
      end

      baseline_ms = timed_ms { Edition.limit(1).count }

      warmup_times_ms = []
      run_times_ms = []
      result_count = nil

      total_elapsed_s = Benchmark.realtime do
        WARMUPS.times do
          elapsed_ms = timed_ms { result_count = run_count(user:, term:) }
          warmup_times_ms << elapsed_ms
        end

        RUNS.times do
          elapsed_ms = timed_ms { result_count = run_count(user:, term:) }
          run_times_ms << elapsed_ms
        end
      end

      first_search_ms = warmup_times_ms.first
      warm_avg_ms = average(warmup_times_ms.drop(1) + run_times_ms)

      puts "count: #{result_count}"
      puts sprintf(
        "baseline query (simple query to show DB connection / cache / memory warm state): %.1f ms",
        baseline_ms,
      )
      puts sprintf(
        "first search (cold run of this specific filter/query shape): %.1f ms",
        first_search_ms,
      )
      puts sprintf(
        "warm avg (average after initial caches/plans are warm): %.1f ms",
        warm_avg_ms,
      )
      puts sprintf(
        "total duration (all warmups + measured runs): %.1fs",
        total_elapsed_s,
      )
    end
  end

  def timed_ms(&block)
    Benchmark.realtime(&block) * 1000.0
  end

  def run_count(user:, term:)
    build_filter(user:, term:).send(:unpaginated_editions).count
  end

  def build_filter(user:, term:)
    options = {
      state: "published",
      include_unpublishing: true,
      include_link_check_report: true,
      include_last_author: true,
      per_page: Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE,
    }

    options[:title] = term if term.present?

    Admin::EditionFilter.new(Edition, user, options)
  end

  def average(values)
    return 0.0 if values.empty?

    values.sum / values.size
  end

  def benchmark_user
    User.where(disabled: false).first || User.first || raise("No users found")
  end
end

EditionFilterBench.run!
