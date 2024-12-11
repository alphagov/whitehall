module Queries
  class VersionPresenter
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

    def ==(other)
      self.class == other.class &&
        version == other.version &&
        action == other.action
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
