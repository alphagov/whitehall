module PublishingApi
  class RolePresenter
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
        title: item.name,
        update_type: update_type,
      ).base_attributes

      content.merge!(
        description: item.responsibilities_without_markup,
        details: details,
        document_type: item.class.name.underscore,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
        schema_name: schema_name,
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
        {
          base_path: "/government/ministers/#{item.slug}",
          routes: [
            {
              path: "/government/ministers/#{item.slug}",
              type: "exact",
            },
          ],
        }
      else
        {
          base_path: nil,
          routes: [],
        }
      end
    end

    def details
      {
        body: body,
        attends_cabinet_type: item.attends_cabinet_type&.name,
        role_payment_type: item.role_payment_type&.name,
        supports_historical_accounts: item.supports_historical_accounts,
      }
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
