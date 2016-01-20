module PublishingApiPresenters
  class TakePart
    attr_reader :take_part_page, :update_type

    def initialize(take_part_page, options = {})
      @take_part_page = take_part_page
      @update_type = options[:update_type] || 'major'
    end

    def base_path
      take_part_page.search_link
    end

    def public_updated_at
      take_part_page.updated_at
    end

    def as_json
      {
        base_path: base_path,
        content_id: take_part_page.content_id,
        title: take_part_page.title,
        description: take_part_page.summary,
        format: "take_part",
        locale: I18n.locale.to_s,
        public_updated_at: public_updated_at,
        update_type: update_type,
        publishing_app: "whitehall",
        rendering_app: "government-frontend",
        routes: [{ path: base_path, type: "exact" }],
        redirects: [],
        details: details
      }
    end

  private

    def details
      {
        body: body,
        image: {
          url: Whitehall.asset_root + take_part_page.image_url(:s300),
          alt_text: take_part_page.image_alt_text,
        }
      }
    end

    def body
      Whitehall::GovspeakRenderer.new.govspeak_to_html(take_part_page.body)
    end
  end
end
