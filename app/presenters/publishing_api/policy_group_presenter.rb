module PublishingApi
  class PolicyGroupPresenter
    include GovspeakHelper

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
        description: item.summary,
        details:,
        document_type: schema_name,
        public_updated_at: item.updated_at,
        rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
        schema_name:,
      )
      content.merge!(PayloadBuilder::PolymorphicPath.for(item))
    end

    def links
      {}
    end

  private

    def schema_name
      "working_group"
    end

    def description
      item.summary # This is deliberately the 'wrong' way around
    end

    def details
      {
        email: item.email,
        body:,
      }.merge(PayloadBuilder::Attachments.for(item))
    end

    def body
      # It looks 'wrong' using the description as the body, but it isn't
      if item.description.present?
        govspeak_to_html(
          item.description,
          attachments: item.attachments,
          alternative_format_contact_email: item.email,
        )
      else
        ""
      end
    end
  end
end
