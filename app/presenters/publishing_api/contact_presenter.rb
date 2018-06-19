module PublishingApi
  class ContactPresenter
    extend Forwardable

    def_delegators :contact,
      :contact_numbers, :content_id, :comments, :country, :email,
      :locality, :postal_code, :recipient, :street_address,
      :title, :contact_form_url, :translation

    def initialize(model, _options)
      @contact = model
    end

    def content
      {
        title: title,
        schema_name: schema_name,
        document_type: document_type,
        locale: locale,
        public_updated_at: public_updated_at,
        publishing_app: "whitehall",
        details: details,
        phase: phase,
        update_type: update_type,
      }
    end

    def links
      links = {}
      links[:world_locations] = [contact.country.content_id] if contact.country

      if contact.contactable
        if contact.contactable.is_a?(::WorldwideOrganisation)
          links[:worldwide_organisations] = [contact.contactable.content_id]
        else
          links[:organisations] = [contact.contactable.content_id]
        end
      end

      links
    end

    def update_type
      "major"
    end

    def phase
      "live"
    end

  private

    attr_reader :contact

    def schema_name
      "contact"
    end

    alias_method :document_type, :schema_name

    def description
      comments
    end

    def locale
      I18n.locale.to_s
    end

    def contact_type
      contact.contact_type.name
    end

    def details
      details = { description: description, contact_type: contact_type, title: title }
      details[:contact_form_links] = [contact_form_links] if contact_form_url
      details[:post_addresses] = [post_address] if postal_code
      details[:email_addresses] = [email_address] if email
      details[:phone_numbers] = phone_numbers if contact_numbers.any?

      details
    end

    def contact_form_links
      {
        title: title,
        link: contact_form_url,
        description: ""
      }
    end

    def post_address
      post_address = {
        title: recipient || title,
        street_address: street_address,
        postal_code: postal_code,
        world_location: country_name
      }

      post_address[:locality] = locality unless locality.nil?

      post_address
    end

    def phone_numbers
      contact_numbers.map do |number|
        {
          title: number.label,
          number: number.number,
        }
      end
    end

    def email_address
      {
        title: recipient || title,
        email: email,
      }
    end

    def country_name
      country.try(:name) || ""
    end

    def updated_at
      translation.updated_at
    end
    alias_method :public_updated_at, :updated_at
  end
end
