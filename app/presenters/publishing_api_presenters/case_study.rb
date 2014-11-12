module PublishingApiPresenters
  class CaseStudy < Struct.new(:edition)
    def base_path
      Whitehall.url_maker.public_document_path(edition)
    end

    def as_json
      {
        title: edition.title,
        base_path: base_path,
        description: edition.summary,
        format: "case_study",
        need_ids: edition.need_ids,
        public_updated_at: edition.public_timestamp,
        update_type: update_type,
        publishing_app: "whitehall",
        rendering_app: "whitehall-frontend",
        routes: [ { path: base_path, type: "exact" } ],
        redirects: [],
        details: details
      }
    end

  private

    def details
      {
        body: "<div class=\"govspeak\"></div>",
        first_published_at: edition.first_public_at,
        change_note: edition.most_recent_change_note,
        tags: {
          browse_pages: [],
          topics: specialist_sectors,
        }
      }
    end

    def update_type
      edition.minor_change? ? 'minor' : 'major'
    end

    def specialist_sectors
      [edition.primary_specialist_sector_tag].compact + edition.secondary_specialist_sector_tags
    end
  end
end
