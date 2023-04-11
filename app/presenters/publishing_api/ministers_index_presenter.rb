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
        title: "Ministers",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        details:,
        document_type: "ministers_index",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "ministers_index",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      {}
    end

  private

    def details
      setting = SitewideSetting.find_by(key: :minister_reshuffle_mode)

      if setting.on
        {
          reshuffle: { message: setting.govspeak },
        }
      else
        {
          body: "Read biographies and responsibilities of [Cabinet ministers](#cabinet-ministers) and all [ministers by department](#ministers-by-department), as well as the [whips](#whips) who help co-ordinate parliamentary business.",
        }
      end
    end

    def base_path
      "/government/ministers"
    end
  end
end
