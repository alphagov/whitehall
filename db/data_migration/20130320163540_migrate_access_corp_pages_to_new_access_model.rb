CorporateInformationPage.where(type_id: 15, organisation_type: 'WorldwideOrganisation').each do |info_page|
  worldwide_organisation = info_page.organisation
  worldwide_organisation.create_access_and_opening_times!(body: info_page.body)
end
