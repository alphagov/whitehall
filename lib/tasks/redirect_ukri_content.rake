desc "Temp rake task to unpublish and redirect content to ukri"
task redirect_ukri_content: :environment do
  ukri_redirects = [
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-slavery-and-human-trafficking-statement-2017-to-2018/innovate-uk-modern-slavery-and-human-trafficking-statement-2017-to-2018", target_url: "https://www.ukri.org/publications/modern-slavery-and-human-trafficking-statements-2016-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-state-aid-funding-policy/innovate-uk-state-aid-funding-policy", target_url: "https://www.ukri.org/publications/innovate-uk-state-aid-funding-policy/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-technology-strategy-board-research-development-and-innovation-scheme/state-aid-notification-innovate-uk-technology-strategy-board-research-development-and-innovation-scheme", target_url: "https://www.ukri.org/publications/innovate-uk-research-development-and-innovation-scheme/state-aid-notification-research-development-innovation-scheme/" },
    { govuk_page: "https://www.gov.uk/government/publications/the-biomedical-catalyst-an-evaluation-report", target_url: "https://www.ukri.org/publications/the-biomedical-catalyst-an-evaluation-report/" },
    { govuk_page: "https://www.gov.uk/government/collections/innovate-uk-action-plans-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/a-mission-oriented-approach-to-building-the-entrepreneurial-state", target_url: "https://www.ukri.org/publications/a-mission-oriented-approach-to-building-the-entrepreneurial-state/" },
    { govuk_page: "https://www.gov.uk/government/publications/additive-manufacturing-mapping-uk-research-into-3d-printing", target_url: "https://www.ukri.org/publications/additive-manufacturing-mapping-uk-research-into-3d-printing/" },
    { govuk_page: "https://www.gov.uk/government/publications/agriculture-and-food-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/built-environment-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/clean-growth-and-infrastructure-annual-review-2020", target_url: "https://www.ukri.org/publications/clean-growth-and-infrastructure-annual-review-2020/" },
    { govuk_page: "https://www.gov.uk/government/publications/creative-industries-strategy-2013-to-2016", target_url: "https://www.ukri.org/publications/creative-industries-strategy-2013-to-2016/" },
    { govuk_page: "https://www.gov.uk/government/publications/design-in-innovation-strategy-2015-to-2020", target_url: "https://www.ukri.org/publications/innovate-uk-design-in-innovation-strategy-2015-to-2019/" },
    { govuk_page: "https://www.gov.uk/government/publications/digital-economy-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/digital-economy-strategy-2015-2018", target_url: "https://www.ukri.org/publications/digital-economy-strategy-2015-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/directors-expenses-for-financial-year-2017-to-2018-innovate-uk", target_url: "https://www.ukri.org/publications/innovate-uk-directors-expenses/" },
    { govuk_page: "https://www.gov.uk/government/publications/directors-expenses-for-the-financial-year-2014-2015", target_url: "https://www.ukri.org/publications/innovate-uk-directors-expenses/" },
    { govuk_page: "https://www.gov.uk/government/publications/electech-sector-a-roadmap-for-the-uk", target_url: "https://www.ukri.org/publications/electech-sector-a-roadmap-for-the-uk/" },
    { govuk_page: "https://www.gov.uk/government/publications/emerging-technologies-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/emerging-technologies-and-industries-strategy-2014-to-2018", target_url: "https://www.ukri.org/publications/emerging-technologies-and-industries-strategy-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/enabling-technologies-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/energy-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/energy-strategy-2012-to-2015", target_url: "https://www.ukri.org/publications/energy-supply-strategy-2012-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/environmental-data-solving-business-problems", target_url: "https://www.ukri.org/publications/environmental-data-solving-business-problems/" },
    { govuk_page: "https://www.gov.uk/government/publications/evaluation-framework", target_url: "https://www.ukri.org/publications/evaluation-framework/" },
    { govuk_page: "https://www.gov.uk/government/publications/evaluation-of-innovation-loans-interim-report", target_url: "https://www.ukri.org/publications/evaluation-of-innovation-loans-interim-report/" },
    { govuk_page: "https://www.gov.uk/government/publications/health-and-care-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/high-value-manufacturing-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/high-value-manufacturing-strategy-2012-to-2015", target_url: "https://www.ukri.org/publications/high-value-manufacturing-strategy-2012-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-board-members-interests", target_url: "https://www.ukri.org/publications/innovate-uk-board-members-interests/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-delivery-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/innovate-uk-delivery-plans-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-delivery-plan-2015-to-2016", target_url: "https://www.ukri.org/publications/innovate-uk-delivery-plans-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-delivery-plan-2016-to-2017", target_url: "https://www.ukri.org/publications/innovate-uk-delivery-plans-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-delivery-plan-2017-to-2018", target_url: "https://www.ukri.org/publications/innovate-uk-delivery-plans-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-gift-and-hospitality-register-2011-to-2012", target_url: "https://www.ukri.org/publications/innovate-uk-hospitality-registers-2011-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-gift-and-hospitality-register-2014-to-2015", target_url: "https://www.ukri.org/publications/innovate-uk-hospitality-registers-2011-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-gift-and-hospitality-register-2017-to-2018", target_url: "https://www.ukri.org/publications/innovate-uk-hospitality-registers-2011-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-helping-innovative-businesses-succeed", target_url: "https://www.ukri.org/publications/innovate-uk-helping-innovative-businesses-succeed/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-materials-and-manufacturing-review", target_url: "https://www.ukri.org/publications/innovate-uk-materials-and-manufacturing-review/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-slavery-and-human-trafficking-statement-2016-to-2017", target_url: "https://www.ukri.org/publications/modern-slavery-and-human-trafficking-statements-2016-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-slavery-and-human-trafficking-statement-2017-to-2018", target_url: "https://www.ukri.org/publications/modern-slavery-and-human-trafficking-statements-2016-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-state-aid-funding-policy", target_url: "https://www.ukri.org/publications/innovate-uk-state-aid-funding-policy/innovate-uk-state-aid-funding-policy/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-strategy-2011-to-2015-concept-to-commercialisation", target_url: "https://www.ukri.org/publications/innovate-uk-concept-to-commercialisation-strategy-2011-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-technology-strategy-board-research-development-and-innovation-scheme", target_url: "https://www.ukri.org/publications/innovate-uk-research-development-and-innovation-scheme/" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-transactions-over-25000", target_url: "https://www.ukri.org/publications/innovate-uk-transactions-over-25000/" },
    { govuk_page: "https://www.gov.uk/government/publications/low-carbon-buildings-best-practices-and-what-to-avoid", target_url: "https://www.ukri.org/publications/non-domestic-buildings-best-practice-and-what-to-avoid/" },
    { govuk_page: "https://www.gov.uk/government/publications/low-carbon-homes-best-strategies-and-pitfalls", target_url: "https://www.ukri.org/publications/low-carbon-homes-best-strategies-and-pitfalls/" },
    { govuk_page: "https://www.gov.uk/government/publications/national-strategy-for-quantum-technologies", target_url: "https://www.ukri.org/publications/national-strategy-for-quantum-technologies/" },
    { govuk_page: "https://www.gov.uk/government/publications/non-animal-technologies-in-the-uk-a-roadmap-strategy-and-vision", target_url: "https://www.ukri.org/publications/non-animal-technologies-in-the-uk-a-roadmap-strategy-and-vision/" },
    { govuk_page: "https://www.gov.uk/government/publications/quantum-technologies-maximising-the-benefits-for-the-uk", target_url: "https://www.ukri.org/publications/quantum-technologies-maximising-the-benefits-for-the-uk/" },
    { govuk_page: "https://www.gov.uk/government/publications/resource-efficiency-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/review-evaluation-of-the-small-business-research-initiative", target_url: "https://www.ukri.org/publications/review-evaluation-of-the-small-business-research-initiative/" },
    { govuk_page: "https://www.gov.uk/government/publications/review-of-uk-proof-of-concept-support", target_url: "https://www.ukri.org/publications/review-of-uk-proof-of-concept-support/" },
    { govuk_page: "https://www.gov.uk/government/publications/scaling-up-the-investor-perspective", target_url: "https://www.ukri.org/publications/scaling-up-the-investor-perspective/" },
    { govuk_page: "https://www.gov.uk/government/publications/space-applications-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/technology-strategy-board-innovate-uk-annual-report-accounts-201617", target_url: "https://www.ukri.org/publications/innovate-uk-annual-report-and-accounts-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/technology-strategy-board-innovate-uk-annual-report-accounts-201718", target_url: "https://www.ukri.org/publications/innovate-uk-annual-report-and-accounts-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/technology-strategy-board-innovate-uk-annual-report-and-accounts-2014-to-2015", target_url: "https://www.ukri.org/publications/innovate-uk-annual-report-and-accounts-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/technology-strategy-board-innovate-uk-annual-report-and-accounts-201516", target_url: "https://www.ukri.org/publications/innovate-uk-annual-report-and-accounts-2014-to-2018/" },
    { govuk_page: "https://www.gov.uk/government/publications/the-business-case-for-adapting-buildings-to-climate-change", target_url: "https://www.ukri.org/publications/the-business-case-for-adapting-buildings-to-climate-change/" },
    { govuk_page: "https://www.gov.uk/government/publications/the-ic-tomorrow-programme-an-evaluation-and-review", target_url: "https://www.ukri.org/publications/the-ic-tomorrow-programme-an-evaluation-and-review/" },
    { govuk_page: "https://www.gov.uk/government/publications/the-immersive-economy-in-the-uk", target_url: "https://www.ukri.org/publications/the-immersive-economy-in-the-uk/" },
    { govuk_page: "https://www.gov.uk/government/publications/the-state-of-eu-medical-device-regulation-readiness-in-uk-smes", target_url: "https://www.ukri.org/publications/the-state-of-eu-medical-device-regulation-readiness-in-uk-smes/" },
    { govuk_page: "https://www.gov.uk/government/publications/transport-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/publications/urban-living-action-plan-2014-to-2015", target_url: "https://www.ukri.org/publications/action-plans-2014-to-2015/" },
    { govuk_page: "https://www.gov.uk/government/case-studies/censo-biotechnologies-global-growth-through-stem-cell-innovation", target_url: "https://www.ukri.org/about-us/research-outcomes-and-impact/innovate-uk/stem-cell-innovation-propels-edinburgh-firm-into-global-markets/" },
    { govuk_page: "https://www.gov.uk/government/case-studies/cyber-security-firm-secures-26-million-series-c-funding", target_url: "https://www.ukri.org/about-us/research-outcomes-and-impact/innovate-uk/cyber-security-firm-reaches-new-markets-with-26-million-funding/" },
    { govuk_page: "https://www.gov.uk/government/case-studies/ellas-kitchen-transforming-the-organic-baby-food-market", target_url: "https://www.ukri.org/about-us/research-outcomes-and-impact/innovate-uk/ellas-kitchen-leads-organic-baby-food-revolution/" },
    { govuk_page: "https://www.gov.uk/government/case-studies/highview-power", target_url: "https://www.ukri.org/about-us/research-outcomes-and-impact/innovate-uk/storing-energy-in-liquid-air-wins-35-million-investment/" },
    { govuk_page: "https://www.gov.uk/government/case-studies/jaguar-land-rover-manufacturing-more-resource-efficient-cars", target_url: "https://www.ukri.org/about-us/research-outcomes-and-impact/innovate-uk/cars-with-up-to-50-recycled-aluminium-in-realcar-project/" },
    { govuk_page: "https://www.gov.uk/government/case-studies/lontra-new-invention-cuts-energy-costs-by-more-than-20", target_url: "https://www.ukri.org/about-us/research-outcomes-and-impact/innovate-uk/new-air-compressor-cuts-energy-costs-by-more-than-20/" },
    { govuk_page: "https://www.gov.uk/government/case-studies/swiftkey-saving-mobile-phone-users-100000-years-of-typing-time", target_url: "https://www.ukri.org/about-us/research-outcomes-and-impact/innovate-uk/swiftkey-saves-mobile-phone-users-100000-years-of-typing-time/" },
  ]

  ukri_redirects.each do |redirect|
    slug = URI.parse(redirect[:govuk_page]).path.split("/").last

    # Rebecca P's user id
    user = User.find(9929)

    published_edition = Document.find_by(slug: slug)&.published_edition

    unless published_edition
      puts "No published edition for GOV.UK page: #{redirect[:govuk_page]}"
      next
    end

    if (pre_pub_edition = published_edition.other_editions.in_pre_publication_state.first)
      edition_deleter = Whitehall.edition_services.deleter(pre_pub_edition)

      if edition_deleter.perform!
        puts "Draft deleted with URL: #{redirect[:govuk_page]}"
      else
        puts edition_deleter.failure_reason
      end
    end

    unpublishing_params = {
      unpublishing_reason_id: UnpublishingReason::Consolidated.id,
      alternative_url: redirect[:target_url],
      redirect: true,
    }

    edition_unpublisher = Whitehall.edition_services.unpublisher(
      published_edition, user: user, remark: "Reset to draft", unpublishing: unpublishing_params
    )

    if edition_unpublisher.perform!
      puts "Redirect successful from: #{redirect[:govuk_page]} to: #{redirect[:target_url]}"
    else
      puts edition_unpublisher.failure_reason
    end
  end
end
