module PublishingApi
  class HowGovernmentWorksPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content_id
      "f56cfe74-8e5c-432d-bfcf-fd2521c5919c"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "How government works",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        description: "About the UK system of government. Understand who runs government, and how government is run.",
        document_type: "special_route",
        public_updated_at: Time.zone.now,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "special_route",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def base_path
      "/government/how-government-works"
    end
  end
end
