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
      remarks = query.remarks
      versions = query.versions

      raw_entries.map do |entry|
        case entry.model
        when "Version"
          versions.fetch(entry.id)
        when "EditorialRemark"
          remarks.fetch(entry.id)
        end
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
end
