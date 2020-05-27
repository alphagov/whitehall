org = WorldwideOrganisation.find_by!(slug: "british-high-commission-vanuatu")
ed = CorporateInformationPage.find(981_490)

EditionWorldwideOrganisation.create!(edition: ed, worldwide_organisation: org)
