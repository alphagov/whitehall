class EmbassyPresenter < SimpleDelegator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  def text
    if SPECIAL_CASES.key?(name)
      "British nationals should contact the #{SPECIAL_CASES[name][:building]} in #{SPECIAL_CASES[name][:location]}."
    elsif offices.empty?
      "British nationals should contact the local authorities."
    elsif has_remote_service?
      "British nationals should contact the #{organisation.name} in #{remote_services_country}."
    end
  end

  def embassy_path
    if SPECIAL_CASES.key?(name)
      link_to(SPECIAL_CASES[name][:building], SPECIAL_CASES[name][:base_path])
    elsif organisation
      link_to(
        organisation.name,
        worldwide_organisation_path(organisation.slug)
      )
    end
  end

  def has_consular_service_in_location?
    ! SPECIAL_CASES.key?(name)
  end

  def has_remote_service?
    remote_services_country.present?
  end

private

  def organisation
    consular_services_organisations.first
  end

  SPECIAL_CASES = {
    "Central African Republic" => {
      building: "Foreign and Commonwealth Office",
      location: "the UK",
      base_path: "/government/organisations/foreign-commonwealth-office",
    },
    "French Polynesia" => {
      building: "British High Commission Wellington",
      location: "New Zealand",
      base_path: "/government/world/organisations/british-high-commission-wellington",
    },
    "Holy See" => {
      building: "British Embassy Rome",
      location: "Italy",
      base_path: "/government/world/organisations/british-embassy-rome",
    },
    "Libya" => {
      building: "British Embassy Tunis",
      location: "Tunisia",
      base_path: "/government/world/organisations/british-embassy-tunis",
    },
    "Liechtenstein" => {
      building: "British Embassy Berne",
      location: "Switzerland",
      base_path: "/government/world/organisations/british-embassy-berne",
    },
    "Macao" => {
      building: "British Consulate General Hong Kong",
      location: "Hong Kong",
      base_path: "/government/world/organisations/british-consulate-general-hong-kong",
    },
    "Maldives" => {
      building: "British High Commission Colombo",
      location: "Sri Lanka",
      base_path: "/government/world/organisations/british-high-commission-colombo",
    },
    "Marshall Islands" => {
      building: "British High Commission Suva",
      location: "Fiji",
      base_path: "/government/world/organisations/british-high-commission-suva",
    },
    "Micronesia" => {
      building: "British High Commission Suva",
      location: "Fiji",
      base_path: "/government/world/organisations/british-high-commission-suva",
    },
    "New Caledonia" => {
      building: "British High Commission Wellington",
      location: "New Zealand",
      base_path: "/government/world/organisations/british-high-commission-wellington",
    },
    "St Martin" => {
      building: "British Embassy Paris",
      location: "France",
      base_path: "/government/world/organisations/british-embassy-paris",
    },
    "Syria" => {
      building: "British Embassy Beirut",
      location: "Lebanon",
      base_path: "/government/world/organisations/british-embassy-beirut",
    },
    "Timor Leste" => {
      building: "British Embassy Jakarta",
      location: "Indonesia",
      base_path: "/government/world/organisations/british-embassy-jakarta",
    },
  }.freeze
end
