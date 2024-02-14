module Presenters::PublishingApi::WorldwideOfficeHelper
  def worldwide_office_details(worldwide_office)
    {
      access_and_opening_times: access_and_opening_times(worldwide_office),
      services: services(worldwide_office),
      type: worldwide_office.worldwide_office_type.name,
    }
  end

private

  def access_and_opening_times(worldwide_office)
    return if worldwide_office.access_and_opening_times.blank?

    Whitehall::GovspeakRenderer.new.govspeak_to_html(worldwide_office.access_and_opening_times)
  end

  def services(worldwide_office)
    worldwide_office.services.map do |service|
      {
        title: service.name,
        type: service.service_type.name,
      }
    end
  end
end
