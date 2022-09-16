module PublishingApi
  class RoleAppointmentPresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      {
        title:,
        locale:,
        details:,
        publishing_app: "whitehall",
        update_type:,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        schema_name: "role_appointment",
      }
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

  private

    def title
      "#{item.person.name} - #{item.role.name}"
    end

    def details
      {
        current: item.current?,
        person_appointment_order: item.id,
      }.tap do |details|
        details[:started_on] = item.started_at.rfc3339 if item.started_at.present?
        details[:ended_on] = item.ended_at.rfc3339 if item.ended_at.present?
      end
    end

    def locale
      I18n.locale.to_s
    end
  end
end
