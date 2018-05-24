module PublishingApi
  class RoleAppointmentPresenter
    attr_accessor :item
    attr_accessor :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    def content_id
      item.content_id
    end

    def content
      content = BaseItemPresenter.new(
        item,
        title: "",
        update_type: update_type,
      ).base_attributes

      content.merge!(
        base_path: nil,
        description: nil,
        details: {},
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        routes: [],
        schema_name: 'role_appointment',
      )
    end

    def links
      {
        person: [
          item.person.content_id,
        ],
        role: [
          item.role.content_id,
        ],
      }
    end
  end
end
