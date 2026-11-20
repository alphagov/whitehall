# frozen_string_literal: true

# Reports what filtering editions by title costs the database, and whether a
# covering index on edition_translations would reduce it.
#
# DEPENDENT ON having a full production database replicated locally.
# Run with:
#   govuk-docker-run bin/rails runner script/explain_edition_title_search.rb
#
# Environment variables:
#   SEARCH_TERM     term to plan for, chosen so it does not look like a slug
#                   (default "evisa")
#   COVERING_INDEX  name of the index being assessed, so that alternative
#                   column orderings can be compared

require "benchmark"
$stdout.sync = true

module EditionTitleSearchExplain
module_function

  COVERING_INDEX = ENV.fetch("COVERING_INDEX", "index_edition_translations_on_locale_and_title_and_edition_id")
  SEARCH_TERM = ENV.fetch("SEARCH_TERM", "evisa")

  def run!
    puts "term:   #{SEARCH_TERM.inspect}"
    puts "locale: #{I18n.default_locale}"

    report_table_size
    report_locales
    report_indexes
    report_scan_costs
    report_subquery_plan
    report_forced_plan if index_exists?
    report_page_query_plan
  end

  def report_table_size
    heading "size of edition_translations"
    print_rows rows(<<~SQL)
      SELECT table_rows,
             ROUND(data_length / 1024 / 1024) AS data_mb,
             ROUND(index_length / 1024 / 1024) AS index_mb
      FROM information_schema.tables
      WHERE table_schema = DATABASE() AND table_name = 'edition_translations'
    SQL
    puts "data_mb is what a title scan reads today. index_mb is every index on the table combined."
  end

  def report_locales
    heading "translations per locale"
    print_rows rows(<<~SQL)
      SELECT locale, COUNT(*) AS translations
      FROM edition_translations
      GROUP BY locale
      ORDER BY translations DESC
      LIMIT 5
    SQL
  end

  def report_indexes
    heading "indexes on edition_translations"
    print_rows rows("SHOW INDEX FROM edition_translations"),
               only: %w[Key_name Seq_in_index Column_name Cardinality]
    puts "#{COVERING_INDEX} #{index_exists? ? 'exists' : 'does not exist yet'}"
  end

  def report_scan_costs
    heading "scan costs"

    narrow = "SELECT COUNT(*) FROM edition_translations WHERE locale = #{quoted_locale}"
    wide = "SELECT COUNT(*) FROM edition_translations WHERE locale = #{quoted_locale} AND title LIKE #{quoted_like}"

    puts "narrow scan, counting rows by locale alone:"
    print_rows rows("EXPLAIN #{narrow}"), only: %w[type key rows Extra]
    _, narrow_ms = timed { rows(narrow) }
    puts format("  %.1f ms", narrow_ms)

    puts
    puts "wide scan, the one a title search runs today:"
    _, wide_ms = timed { rows(wide) }
    puts format("  %.1f ms", wide_ms)

    puts
    if narrow_ms.positive?
      puts format("the wide scan costs %.1f times the narrow one", wide_ms / narrow_ms)
    end
    puts "a covering index would land between the two: it scans every row, but reads a narrow key rather than the full row."
  end

  def report_subquery_plan
    heading "plan for the title subquery"
    explain = rows("EXPLAIN #{subquery}")
    print_rows explain, only: %w[type possible_keys key rows filtered Extra]
    _, unforced_ms = timed { rows(subquery) }
    puts format("  %.1f ms", unforced_ms)
    puts verdict(explain.first)
  end

  def report_forced_plan
    heading "plan with the covering index forced"
    forced = subquery(force_index: COVERING_INDEX)
    print_rows rows("EXPLAIN #{forced}"), only: %w[type key rows Extra]
    _, forced_ms = timed { rows(forced) }
    puts format("  %.1f ms", forced_ms)
    puts "if this is much faster than the unforced plan, the index helps but the optimiser is not choosing it."
  end

  def report_page_query_plan
    heading "plan for the page query the admin screen runs"
    puts Edition.active.with_title_containing(SEARCH_TERM).order("editions.updated_at DESC").limit(15).explain.inspect
  end

  def verdict(explain_row)
    key = explain_row["key"].presence
    extra = explain_row["Extra"].presence

    if key == COVERING_INDEX && extra.to_s.include?("Using index")
      "PASS: the scan reads #{COVERING_INDEX} alone, without touching the table."
    elsif key == COVERING_INDEX
      "FAIL: #{COVERING_INDEX} is used but the scan still reads the table (Extra: #{extra || 'none'}). The index is not covering, so it will not help."
    else
      "no covering index in use (key: #{key || 'none'}, Extra: #{extra || 'none'})."
    end
  end

  def subquery(force_index: nil)
    from = force_index ? "edition_translations FORCE INDEX (#{force_index})" : "edition_translations"

    "SELECT edition_id FROM #{from} WHERE locale = #{quoted_locale} AND title LIKE #{quoted_like}"
  end

  def index_exists?
    return @index_exists if defined?(@index_exists)

    @index_exists = connection.index_name_exists?(:edition_translations, COVERING_INDEX).present?
  end

  def quoted_locale
    connection.quote(I18n.default_locale.to_s)
  end

  def quoted_like
    connection.quote("%#{ActiveRecord::Base.sanitize_sql_like(SEARCH_TERM)}%")
  end

  def rows(statement)
    connection.select_all(statement).to_a
  end

  def connection
    @connection ||= ActiveRecord::Base.lease_connection
  end

  def timed
    value = nil
    elapsed = Benchmark.realtime { value = yield }
    [value, elapsed * 1000.0]
  end

  def heading(title)
    puts
    puts "=== #{title} ==="
  end

  def print_rows(table, only: nil)
    return puts "(no rows)" if table.empty?

    columns = only ? only & table.first.keys : table.first.keys
    widths = columns.index_with do |column|
      ([column] + table.map { |row| row[column].to_s }).map(&:length).max
    end

    puts columns.map { |column| column.ljust(widths[column]) }.join("  ")
    puts columns.map { |column| "-" * widths[column] }.join("  ")
    table.each do |row|
      puts columns.map { |column| row[column].to_s.ljust(widths[column]) }.join("  ")
    end
  end
end

EditionTitleSearchExplain.run!
