module PublishingApi
  class ContactPresenter
    extend Forwardable

    def_delegators :contact,
      :contact_numbers, :content_id, :comments, :country, :email,
      :locality, :region, :postal_code, :recipient, :street_address,
      :title, :contact_form_url, :translation

    def initialize(model, _options)
      @contact = model
    end

    def content
      {
        title: title,
        description: comments.presence,
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

    def locale
      I18n.locale.to_s
    end

    def contact_type
      contact.contact_type.name
    end

    def details
      details = {
        title: title,
        description: comments.presence,
        contact_type: contact_type,
      }.compact

      details[:contact_form_links] = [contact_form_links] if contact_form_url.present?
      details[:post_addresses] = post_addresses
      details[:email_addresses] = [email_address] if email.present?
      details[:phone_numbers] = phone_numbers if contact_numbers.any?

      details
    end

    def contact_form_links
      {
        link: contact_form_url,
      }
    end

    def post_addresses
      # These are the required fields for the schema
      return [] if !street_address.present? || !country

      post_address = {
        title: recipient.presence,
        street_address: street_address.presence,
        locality: locality.presence,
        region: region.presence,
        postal_code: postal_code.presence,
        world_location: country&.name,
        iso2_country_code: country&.iso2&.downcase,
      }

      [post_address.compact]
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
        title: recipient.presence,
        email: email,
      }.compact
    end

    def updated_at
      translation.updated_at
    end
    alias_method :public_updated_at, :updated_at
  end
end
