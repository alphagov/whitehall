module PublishingApi
  class RolePresenter
    attr_accessor :item, :update_type

    def initialize(item, update_type: nil)
      self.item = item
      self.update_type = update_type || "major"
    end

    delegate :content_id, to: :item

    def content
      content = BaseItemPresenter.new(
        item,
        title: item.name,
        update_type:,
      ).base_attributes

      content.merge!(
        description: item.responsibilities_without_markup,
        details:,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name:,
      )
      content.merge!(polymorphic_path)
    end

    def links
      {
        ordered_parent_organisations: item.organisations.pluck(:content_id).compact,
      }
    end

  private

    def schema_name
      "role"
    end

    def polymorphic_path
      # Roles other than ministerial roles don't have base paths
      if item.is_a?(MinisterialRole)
        PayloadBuilder::PolymorphicPath.for(item)
      else
        {
          base_path: nil,
          routes: [],
        }
      end
    end

    def whip
      return {} if item.whip_organisation_id.nil?

      whip_organisation = Whitehall::WhipOrganisation.find_by_id(item.whip_organisation_id)

      {
        sort_order: whip_organisation.sort_order,
        label: whip_organisation.label,
      }
    end

    def details
      {
        body:,
        attends_cabinet_type: item.attends_cabinet_type&.name,
        role_payment_type: item.role_payment_type&.name,
        supports_historical_accounts: item.supports_historical_accounts,
        whip_organisation: whip,
      }.merge(ministerial_role_details)
    end

    def ministerial_role_details
      return {} unless item.is_a?(MinisterialRole)

      { seniority: item.seniority }
    end

    def body
      [
        {
          content_type: "text/govspeak",
          content: item.responsibilities || "",
        },
      ]
    end
  end
end
