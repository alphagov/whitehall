require_relative '../publishing_api_presenters'

class PublishingApiPresenters::Organisation < PublishingApiPresenters::Placeholder
  include ApplicationHelper

  def details
    super.tap do |d|
      d[:brand] = brand
      d[:logo]  = {
        formatted_title: formatted_title,
        crest: crest,
      }
    end
  end

private

  def crest
    item.organisation_logo_type.class_name
  end

  def formatted_title
    format_with_html_line_breaks(item.logo_formatted_name)
  end

  def brand
    brand_colour = item.organisation_brand_colour
    brand_colour ? brand_colour.class_name : nil
  end
end
