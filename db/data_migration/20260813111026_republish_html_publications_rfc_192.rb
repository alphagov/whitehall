def migrate
  invalid_html_publication_base_paths.each do |invalid_html_publication_base_path|
    old_slug = invalid_html_publication_base_path.split("/").last
    publication_slug = invalid_html_publication_base_path.split("/")[-2]
    matching_editions = Edition.where(state: %w[published withdrawn], slug: publication_slug)

    if matching_editions.count.zero? || matching_editions.count > 1
      puts("ERROR couldn't find exactly 1 published edition for publication #{publication_slug}")
      next
    end

    ed = matching_editions.first
    html_attachment = ed.html_attachments.where(slug: old_slug).first

    if html_attachment.nil?
      puts("ERROR couldn't find attachment: #{invalid_html_publication_base_path} in publication")
      next
    end

    new_slug = fixed_slug(old_slug)
    puts("Altering #{old_slug} to #{new_slug}")
    validator = GdsApi::Validators::BasePathValidator.new("/#{new_slug}")
    unless validator.valid?
      puts("WARNING: RFC-192 validation failed! #{validator.errors}")
      next
    end

    html_attachment.update!(slug: new_slug)
    Whitehall::PublishingApi.republish_async(html_attachment)
    # send edition to publishing api
    PublishingApiDocumentRepublishingJob.new.perform(ed.document.id)
  end
end

def fixed_slug(old_slug)
  old_slug.downcase.gsub("_", "-")
end

def invalid_html_publication_base_paths
  [
    "/government/calls-for-evidence/call-for-evidence-to-identify-uk-interest-in-existing-eu-trade-remedy-measures/provisional-findings-of-the-call-for-evidence-into-UK-interest-in-existing-EU-trade-remedy-measures",
    "/government/publications/12-may-2026-acnfp-pgt-subcommittee-meeting/24th-meeting-of-the-acnfp_pgt-12th-may-2026-agenda",
    "/government/publications/20-january-2026-acnfp-ccp-subcommittee-meeting/4th-meeting-of-the-acnfp_ccp-20th-january-2026-agenda",
    "/government/publications/2019-to-2020-gca-annual-report-and-accounts/hc349_gca_annual_report_and_accounts_2019-2020",
    "/government/publications/accessing-government-secured-flu-vaccines-guidance-for-primary-care-in-england-for-2021-to-2022/accessing-government-secured-flu-vaccines-guidance-for-primary-care-in-England-for-2021-to-2022",
    "/government/publications/acnfp-subgroup-members/acnfp_ccp-subcommittee",
    "/government/publications/acnfp-subgroup-members/acnfp_pgt-subcommittee",
    "/government/publications/cabinet-office-spend-control-data-for-january-to-march-2022/cabinet-office-spend-controls-q4_-2021-22",
    "/government/publications/central-african-republic-list-of-translators-and-interpreters/car_list-of-translators-and-interpreters",
    "/government/publications/early-access-to-medicines-scheme-eams-scientific-opinion-remdesivir-in-the-treatment-of-patients-hospitalised-with-suspected-or-laboratory-confirme/treatment-protocol-for-healthcare-professionals_eams-119720001-remdesivir-100-mg-powder-for-concentrate-for-solution-for-infusion",
    "/government/publications/early-access-to-medicines-scheme-eams-scientific-opinion-remdesivir-in-the-treatment-of-patients-hospitalised-with-suspected-or-laboratory-confirme/treatment-protocol-for-patients_eams-119720001-remdesivir-100-mg-powder-for-concentrate-for-solution-for-infusion",
    "/government/publications/early-access-to-medicines-scheme-eams-scientific-opinion-remdesivir-in-the-treatment-of-patients-hospitalised-with-suspected-or-laboratory-confirme/treatment-protocol-for-patients_eams-119720002-remdesivir-100-mg-concentrate-for-solution-for-infusion",
    "/government/publications/foi-release-fcdo-services-bacs-software-supplier/foi2024_00006s-fcdo-services-bacs-software-supplier",
    "/government/publications/foi-release-fcdo-services-hardware-and-software-procurement/foi2024_00003s",
    "/government/publications/foi-release-health-and-safety-and-compliance-e-learning-courses/foi2024_00011s-health-and-safety-and-compliance-e-learning-courses",
    "/government/publications/foi-release-investment-pools/foi2025_00002s-investment-pools",
    "/government/publications/foi-release-kings-messengers-workforce/foi2024_00002s",
    "/government/publications/foi-release-pay-of-full-time-equivalent-employees/foi2024_00013s-pay-of-full-time-equivalent-employees",
    "/government/publications/foi-release-provision-of-an-enterprise-health-and-safety-system-tender/foi2024_01569",
    "/government/publications/foi-release-revenue-related-to-film-and-television-productions/foi2024_00005s",
    "/government/publications/foi-release-social-media-management/foi-2024_00004s",
    "/government/publications/foi-release-spend-on-office-supplies/foi2024_00001s",
    "/government/publications/foi-release-top-ten-suppliers/foi2024_00010s-top-ten-suppliers",
    "/government/publications/insolvency-service-foi-responses-april-to-june-2021/foi2021_22-017-trading-names-and-dates-of-bankrupt-firms-2007-2017",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-058-iva-stats-between-the-years-of-2012-and-2022",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-059-the-number-of-business-insolvencies-split-by-region-over-the-years-2005-2020",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-061-redundancy-payments-since-jan-2019",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-062-staffing-query",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-064-software-contracts",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-067-lan-contract",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-072-information-about-bankruptcy-creditors-committee",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-073-dros-broken-down-by-intermediaries-2020-2022",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-074-records-management-contract",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-075-compensation-orders",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-076-data-centre-and-servers",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-077-disqualification-orders-both-sought-and-successful",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-085-payments-made-to-employees-by-inssrps",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-095-edenred-and-the-insolvency-service",
    "/government/publications/insolvency-service-foi-responses-october-to-december-2022/foi22_23-096-companies-registered-at-companies-house-information",
    "/government/publications/project-gigabit-uk-subsidy-advice/gigabit_infrastructure_detailed_overview_v06",
    "/government/publications/space-for-all-fund-2023/template-uk-space-agency-low-value-grant-funding-agreement_sfa-2023",
  ]
end

migrate
