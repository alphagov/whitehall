module Admin::WorldwideOrganisationsHelper
  def worldwide_office_shown_on_home_page_text(worldwide_organisation, worldwide_office)
    if worldwide_organisation.is_main_office?(worldwide_office)
      "Yes (as main office)"
    elsif worldwide_organisation.office_shown_on_home_page?(worldwide_office)
      "Yes"
    else
      "No"
    end
  end

  def ordered_worldwide_offices(worldwide_organisation)
    ([worldwide_organisation.main_office] + [worldwide_organisation.home_page_offices] + [worldwide_organisation.other_offices]).flatten.uniq
  end

  def any_translated_worldwide_offices?(worldwide_organisation)
    worldwide_organisation.offices.map(&:contact).any? { |contact| contact.non_english_localised_models([:contact_numbers]).present? }
  end
end
