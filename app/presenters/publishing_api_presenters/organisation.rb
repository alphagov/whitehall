module PublishingApiPresenters
  class Organisation < Item
    include ApplicationHelper

    def links
      {}
    end

    def title
      item.name
    end

    def description
      nil
    end

    def schema_name
      "placeholder"
    end

    def document_type
      item.class.name.underscore
    end

    def public_updated_at
      item.updated_at
    end

    def details
      super.merge(
        brand: brand,
        logo: {
          formatted_title: formatted_title,
          crest: crest,
        },
      )
    end

  private

    def crest
      crest_is_publishable? ? item.organisation_logo_type.class_name : nil
    end

    def crest_is_publishable?
      class_name = item.organisation_logo_type.class_name
      class_name != "no-identity" && class_name != "custom"
    end

    def formatted_title
      format_with_html_line_breaks(item.logo_formatted_name)
    end

    def brand
      brand_colour = item.organisation_brand_colour
      brand_colour ? brand_colour.class_name : nil
    end
  end
end
