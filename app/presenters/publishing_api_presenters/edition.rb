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

    def as_json
      {
        content_id: edition.content_id,
        title: edition.title,
        description: edition.summary,
        format: "placeholder",
        locale: I18n.locale.to_s,
        need_ids: edition.need_ids,
        public_updated_at: edition.public_timestamp,
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

  private

    # An incomplete and temporary details hash that only currently includes
    # specialist topics. This is to enable the email alerts service to generate
    # email alerts based on taggings to topics.
    #
    # Note that we are referencing tags using the temporary `tags` hash here in
    # `details` instead of the top-level `links` hash because topics are not yet
    # being registered in the content store. Once they are available in the
    # content store, the `links` hash should be used instead.
    #
    # Note also that the `browse_pages` key is here as a marker for a future
    # feature where email alerts will be generated based on taggings to browse
    # pages. Again, this should be moved to the `links` hash at the earliest
    # possible time.
    def details
      {
        change_note: edition.most_recent_change_note,
        tags: {
          browse_pages: [],
          topics: specialist_sectors,
        }
      }
    end

    def default_update_type
      edition.minor_change? ? 'minor' : 'major'
    end

    def specialist_sectors
      [edition.primary_specialist_sector_tag].compact + edition.secondary_specialist_sector_tags
    end
  end
end
