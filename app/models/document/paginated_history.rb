class Document::PaginatedHistory
  PER_PAGE = 30

  attr_reader :document, :query
  delegate :total_count, to: :query

  def initialize(document, page)
    @document = document
    @query = document.edition_versions
                     .includes(:user)
                     .where.not(state: :superseded)
                     .reorder(created_at: :desc, id: :desc)
                     .page(page)
                     .per(PER_PAGE)
  end

  def audit_trail
    query.map.with_index do |version, index|
      # [index - 1] returns next version, as array has newest first
      AuditTrailEntry.new(version,
                          is_first_edition: version.item_id == first_edition&.id,
                          next_version: query[index + 1])
    end
  end

private

  def first_edition
    # probably should be a method on document for this
    @first_edition ||= document.editions.where.not(state: :deleted).order(id: :asc).first
  end

  class AuditTrailEntry
    attr_reader :version, :is_first_edition, :preloaded_next_version
    delegate :created_at, to: :version

    def initialize(version, is_first_edition:, next_version: nil)
      @version = version
      @is_first_edition = is_first_edition
      @preloaded_next_version = next_version
    end

    def actor
      version.user
    end

    def next_version
      # we can avoid n+1 queries by using our preloaded_next_version
      @next_version ||= preloaded_next_version || version.next
    end

    def action
      case version.event
      when "create"
        is_first_edition ? "created" : "editioned"
      else
        next_version&.state != version.state ? version.state : "updated"
      end
    end
  end
end

