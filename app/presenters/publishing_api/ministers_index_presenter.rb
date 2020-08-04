module PublishingApi
  class MinistersIndexPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content_id
      "324e4708-2285-40a0-b3aa-cb13af14ec5f"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "ministers_index",
        update_type: update_type,
      ).base_attributes

      content.merge!(
        base_path: base_path,
        details: details,
        document_type: "ministers_index",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "ministers_index",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

  private

    def details
      setting = SitewideSetting.find_by(key: :minister_reshuffle_mode)

      return {} unless setting.on

      { reshuffle: { message: setting.govspeak } }
    end

    def base_path
      return "/government/ministers" if I18n.locale == :en

      "/government/ministers.#{I18n.locale}"
    end
  end
end
