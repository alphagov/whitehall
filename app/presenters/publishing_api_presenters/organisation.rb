require_relative '../publishing_api_presenters'

class PublishingApiPresenters::Organisation < PublishingApiPresenters::Placeholder
  def details
    super.tap do |d|
      d[:brand] = brand
    end
  end

private

  def brand
    brand_colour = item.organisation_brand_colour
    brand_colour ? brand_colour.class_name : nil
  end
end
