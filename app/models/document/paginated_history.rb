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
    first_edition_id = document.editions.first&.id
    query.map.with_index do |version, index|
      AuditTrailEntry.new(version,
                          is_first_edition: version.item_id == first_edition_id,
                          previous_version: query[index + 1])
    end
  end

  class AuditTrailEntry
    extend ActiveModel::Naming

    def self.model_name
      ActiveModel::Name.new(Version, nil)
    end

    attr_reader :version

    delegate :created_at, :to_key, to: :version

    def initialize(version, is_first_edition:, previous_version: nil)
      @version = version
      @is_first_edition = is_first_edition
      @preloaded_previous_version = previous_version
    end

    def actor
      version.user
    end

    def action
      case version.event
      when "create"
        @is_first_edition ? "created" : "editioned"
      else
        previous_version&.state != version.state ? version.state : "updated"
      end
    end

  private

    def previous_version
      # we can avoid n+1 queries by using our preloaded_prev_version
      @previous_version ||= @preloaded_previous_version || version.previous
    end
  end
end
