class Document::PaginatedHistory
  attr_reader :document, :query
  delegate :total_count, to: :query

  def initialize(document, page)
    @document = document
    @query = document.edition_versions
                     .includes(:user)
                     .where.not(state: :superseded)
                     .reorder(created_at: :desc, id: :desc)
                     .page(page)
                     .per(30)
  end

  def audit_trail
    query.map.with_index do |version, index|
      AuditTrailEntry.new(version,
                          is_first_edition: version.item_id == first_edition&.id,
                          previous_version: index == 0 ? nil : query[index - 1])
    end
  end

private

  def first_edition
    # probably should be a method on document for this
    @first_edition ||= document.editions.where.not(state: :deleted).order(id: :asc).first
  end

  class AuditTrailEntry
    attr_reader :version, :is_first_edition, :preloaded_previous_version
    delegate :created_at, to: :version

    def initialize(version, is_first_edition:, previous_version: nil)
      @version = version
      @is_first_edition = is_first_edition
      @preloaded_previous_version = previous_version
    end

    def actor
      version.user
    end

    def previous_version
      # we can avoid n+1 queries by using our preloaded_previous_version
      @previous_version ||= preloaded_previous_version || version.previous
    end

    def action
      case version.event
      when "create"
        "editioned"
        is_first_edition ? "created" : "editioned"
      else
        previous_version&.state != version.state ? version.state : "updated"
      end
    end
  end
end

