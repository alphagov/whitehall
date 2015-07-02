# For now, this is used to register dummy editions in the content store as
# "placeholder" content items. Only the specialist topics information is
# exposed. This is to enable the email alerts service to generate alerts
# when content is tagged to these topics.
module PublishingApiPresenters
  class Edition
    attr_reader :edition, :update_type

    def initialize(edition, options = {})
      @edition = edition
      @update_type = options[:update_type] || default_update_type
    end

    def base_path
      Whitehall.url_maker.public_document_path(edition)
    end

    def public_updated_at
      # If there is no public_timestamp, the edition should be a draft
      edition.public_timestamp || edition.updated_at
    end

    def as_json
      if edition.access_limited? && !edition.publicly_visible?
        standard_fields.merge(access_limited: access_limited)
      else
        standard_fields
      end
    end

  private

    def standard_fields
      {
        content_id: edition.content_id,
        title: edition.title,
        description: edition.summary,
        format: "placeholder",
        locale: I18n.locale.to_s,
        need_ids: edition.need_ids,
        public_updated_at: public_updated_at,
        update_type: update_type,
        publishing_app: "whitehall",
        # We're not using edition.rendering_app because we're defaulting to a
        # placeholder and placeholders only exist because they are rendered by whitehall
        rendering_app: "whitehall-frontend",
        routes: [ { path: base_path, type: "exact" } ],
        redirects: [],
        details: details
      }
    end

    def details
      {
        change_note: edition.most_recent_change_note,
        # These tags are used downstream for sending email alerts.
        # For more details please see https://gov-uk.atlassian.net/wiki/display/TECH/Email+alerts+2.0
        tags: {
          browse_pages: [],
          policies: policies,
          topics: specialist_sectors,
        }
      }
    end

    def policies
      if edition.can_be_related_to_policies?
        [
          edition.policy_areas.map(&:slug),
          edition.policies.map(&:slug),
        ].flatten.uniq
      else
        []
      end
    end

    def default_update_type
      edition.minor_change? ? 'minor' : 'major'
    end

    def specialist_sectors
      [edition.primary_specialist_sector_tag].compact + edition.secondary_specialist_sector_tags
    end

    def access_limited
      {
        users: users.map(&:uid).compact
      }
    end

    def users
      @users ||= User.where(organisation: edition.organisations)
    end
  end
end
