module PublishingApiPresenters
  class Item
    extend Forwardable

    def_delegators :item, :base_path, :content_id, :title, :description, :need_ids, :public_updated_at
    attr_accessor :update_type

    def initialize(item, update_type: "major")
      self.update_type = update_type
      self.item = item
    end

    def content
      {
        base_path: base_path,
        title: title,
        description: description,
        format: document_format,
        locale: I18n.locale.to_s,
        need_ids: need_ids,
        public_updated_at: public_updated_at,
        publishing_app: "whitehall",
        rendering_app: rendering_app,
        routes: routes,
        redirects: [],
        details: details
      }
    end

    def links
      {}
    end

    private
    attr_accessor :item

    def rendering_app
      "whitehall-frontend"
    end

    def routes
      [{ path: base_path, type: "exact" }]
    end
  end
end
