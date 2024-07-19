module PublishingApi
  class RedirectPresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      {
        locale: I18n.locale.to_s,
        base_path: item.public_path(locale: I18n.locale),
        document_type: "redirect",
        schema_name: "redirect",
        redirects:,
        publishing_app: Whitehall::PublishingApp::WHITEHALL,
        update_type:,
      }
    end

    def links
      {}
    end

  private

    def redirects
      [{
        path: item.public_path(locale: I18n.locale),
        type: "exact",
        destination: item.api_presenter_redirect_to,
      }]
    end
  end
end
