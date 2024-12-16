class Document::PaginatedTimeline
  attr_reader :document, :page, :only

  def initialize(document:, page:, only: nil)
    @document = document
    @page = page.to_i
    @only = only
  end

  def entries
    @entries ||= begin
      raw_entries = query.raw_entries
      remarks = document.remarks_by_ids(query.remark_ids)
      versions = document.decorated_edition_versions_by_ids(query.version_ids)

      versions_and_remarks = raw_entries.map do |entry|
        case entry.model
        when "Version"
          versions.fetch(entry.id)
        when "EditorialRemark"
          remarks.fetch(entry.id)
        end
      end

      if only.present?
        versions_and_remarks
      else
        [*versions_and_remarks, *host_content_update_events].sort_by(&:created_at).reverse!
      end
    end
  end

  def query
    @query ||= Document::PaginatedTimelineQuery.new(document:, page:, only:)
  end

  def entries_on_newer_editions(edition)
    @entries_on_newer_editions ||= entries.select do |entry|
      if entry.is_a?(EditorialRemark)
        entry.edition_id > edition.id
      else
        entry.item_id > edition.id
      end
    end
  end

  def entries_on_current_edition(edition)
    @entries_on_current_edition ||= entries.select do |entry|
      if entry.is_a?(EditorialRemark)
        entry.edition_id == edition.id
      else
        entry.item_id == edition.id
      end
    end
  end

  def entries_on_previous_editions(edition)
    @entries_on_previous_editions ||= entries.select do |entry|
      if entry.is_a?(EditorialRemark)
        entry.edition_id < edition.id
      else
        entry.item_id < edition.id
      end
    end
  end

  def total_count
    @total_count || query.total_count
  end

  def total_pages
    (total_count / Document::PaginatedTimelineQuery::PER_PAGE.to_f).ceil
  end

  def current_page
    @page
  end

  def limit_value
    Document::PaginatedTimelineQuery::PER_PAGE
  end

  def next_page
    if current_page < total_pages
      current_page + 1
    else
      false
    end
  end

  def prev_page
    if current_page > 1
      current_page - 1
    else
      false
    end
  end

private

  def host_content_update_events
    return [] if query.raw_entries.empty?

    @host_content_update_events ||= HostContentUpdateEvent.all_for_date_window(
      document:,
      from: date_window.last,
      to: date_window.first,
    )
  end

  def date_window
    @date_window ||= begin
      start = page == 1 ? Time.zone.now : query.raw_entries.first.created_at
      ends = next_page_entries ? next_page_entries.first.created_at : query.raw_entries.last.created_at
      (start.to_time.round.utc..ends.to_time.round.utc)
    end
  end

  def next_page_entries
    if next_page
      Document::PaginatedTimelineQuery.new(document:, page: next_page, only:).raw_entries
    end
  end
end
