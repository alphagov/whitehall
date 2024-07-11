module Admin::WorldwideOrganisationsHelper
  def ordered_worldwide_offices(worldwide_organisation)
    ([worldwide_organisation.main_office] + [worldwide_organisation.home_page_offices] + [worldwide_organisation.other_offices]).flatten.uniq
  end

  def any_translated_worldwide_offices?(worldwide_organisation)
    worldwide_organisation.offices.map(&:contact).any? { |contact| contact.non_english_localised_models([:contact_numbers]).present? }
  end
end
