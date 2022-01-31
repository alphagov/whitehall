desc "Temp rake task to unpublish content belonging to ukri"
task unpublish_ukri_content: :environment do
  content_to_unpublish = [
    { govuk_page: "https://www.gov.uk/government/organisations/innovate-uk/about-our-services" },
    { govuk_page: "https://www.gov.uk/government/publications/future-building-a-strategy-for-low-impact-building" },
    { govuk_page: "https://www.gov.uk/government/publications/future-cities-dialogue-investigating-uk-urban-system-integration" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-how-catapults-can-help-your-business-innovate" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-organisation-chart" },
    { govuk_page: "https://www.gov.uk/government/publications/sbri-transport-priorities-review-for-ukri-report" },
    { govuk_page: "https://www.gov.uk/government/case-studies/3d-scanning-measuring-how-wounds-heal" },
    { govuk_page: "https://www.gov.uk/government/case-studies/act-blade" },
    { govuk_page: "https://www.gov.uk/government/case-studies/aerospace-supply-chain-seeks-alternatives-to-hazardous-chemicals" },
    { govuk_page: "https://www.gov.uk/government/case-studies/agroceutical-products-a-better-life-for-alzheimers-patients" },
    { govuk_page: "https://www.gov.uk/government/case-studies/alert-technology-saving-lives-with-better-asbestos-detection" },
    { govuk_page: "https://www.gov.uk/government/case-studies/anvil-semiconductors-lighting-the-way-on-led-technology" },
    { govuk_page: "https://www.gov.uk/government/case-studies/arrival-innovate-uk-backed-firm-achieves-unicorn-status" },
    { govuk_page: "https://www.gov.uk/government/case-studies/assisted-living-reinventing-locks-to-support-vulnerable-people" },
    { govuk_page: "https://www.gov.uk/government/case-studies/avanti-pioneering-satellite-communications-across-the-world" },
    { govuk_page: "https://www.gov.uk/government/case-studies/beattie-passive-opens-new-factory-to-meet-demand-for-retrofit" },
    { govuk_page: "https://www.gov.uk/government/case-studies/biosignatures-new-cancer-screening-technology-set-for-approval" },
    { govuk_page: "https://www.gov.uk/government/case-studies/bladon-jets-innovative-mobile-and-low-cost-generator-takes-off" },
    { govuk_page: "https://www.gov.uk/government/case-studies/buffalogrid" },
    { govuk_page: "https://www.gov.uk/government/case-studies/buffalogrid-connecting-the-next-1-billion-to-the-internet" },
    { govuk_page: "https://www.gov.uk/government/case-studies/c-enduro-a-boat-that-goes-the-distance" },
    { govuk_page: "https://www.gov.uk/government/case-studies/cellcentric-trialling-a-new-drug-for-late-stage-prostate-cancer" },
    { govuk_page: "https://www.gov.uk/government/case-studies/ceres-power-fuel-cell-business-makes-manufacturing-breakthrough" },
    { govuk_page: "https://www.gov.uk/government/case-studies/charity-engine-power-of-home-pcs-harnessed-as-one-supercomputer" },
    { govuk_page: "https://www.gov.uk/government/case-studies/charm-impact" },
    { govuk_page: "https://www.gov.uk/government/case-studies/chiaro-uk-tech-company-develops-pelvic-floor-exercise-tracker" },
    { govuk_page: "https://www.gov.uk/government/case-studies/citi-logik-planning-for-tomorrows-smart-cities" },
    { govuk_page: "https://www.gov.uk/government/case-studies/cleaner-power-and-lower-bills-making-community-energy-work" },
    { govuk_page: "https://www.gov.uk/government/case-studies/clever-engineering-macrete-bridges-the-technology-gap" },
    { govuk_page: "https://www.gov.uk/government/case-studies/connected-car-firm-lightfoot-receives-1-million-innovation-loan" },
    { govuk_page: "https://www.gov.uk/government/case-studies/cumulus-aims-to-transform-the-renewable-energy-market" },
    { govuk_page: "https://www.gov.uk/government/case-studies/cutecircuit-clothing-the-wearer-in-immersive-sound" },
    { govuk_page: "https://www.gov.uk/government/case-studies/data-innovation-igeolise-turns-distance-into-time" },
    { govuk_page: "https://www.gov.uk/government/case-studies/dearman-technology-firm-drives-a-cold-and-power-revolution" },
    { govuk_page: "https://www.gov.uk/government/case-studies/delta-motorsport-low-carbon-technologies-help-business-to-grow" },
    { govuk_page: "https://www.gov.uk/government/case-studies/demand-logic-energy-savings-breakthrough-in-buildings" },
    { govuk_page: "https://www.gov.uk/government/case-studies/demand-logic-explores-world-market-for-energy-data-analysis" },
    { govuk_page: "https://www.gov.uk/government/case-studies/deos-delivering-faster-and-better-mobile-medical-screening" },
    { govuk_page: "https://www.gov.uk/government/case-studies/deregallera-improving-the-range-of-electric-vehicles" },
    { govuk_page: "https://www.gov.uk/government/case-studies/diabetes-management-transformed-with-ai-powered-app" },
    { govuk_page: "https://www.gov.uk/government/case-studies/divido-revolutionising-point-of-purchase-finance" },
    { govuk_page: "https://www.gov.uk/government/case-studies/dressipi-fashioning-your-own-digital-wardrobe" },
    { govuk_page: "https://www.gov.uk/government/case-studies/drive-system-design-motoring-ahead-with-expansion-in-the-us" },
    { govuk_page: "https://www.gov.uk/government/case-studies/energy-efficient-cooking-locooker-steams-ahead" },
    { govuk_page: "https://www.gov.uk/government/case-studies/extracare-building-better-lives-for-older-people" },
    { govuk_page: "https://www.gov.uk/government/case-studies/feminine-care-innovator-boosted-by-1-million-innovate-uk-loan" },
    { govuk_page: "https://www.gov.uk/government/case-studies/gaist-firm-quadruples-staff-thanks-to-roads-management-system" },
    { govuk_page: "https://www.gov.uk/government/case-studies/genetic-lego-a-step-change-in-dna-engineering" },
    { govuk_page: "https://www.gov.uk/government/case-studies/genomics-plc-analytics-driving-a-revolution-in-healthcare" },
    { govuk_page: "https://www.gov.uk/government/case-studies/gordon-murray-design-poised-to-revolutionise-the-cars-we-drive" },
    { govuk_page: "https://www.gov.uk/government/case-studies/gordon-murray-formula-one-design-comes-to-mass-car-production" },
    { govuk_page: "https://www.gov.uk/government/case-studies/gravitricity" },
    { govuk_page: "https://www.gov.uk/government/case-studies/green-innovation-recycling-waste-into-building-blocks" },
    { govuk_page: "https://www.gov.uk/government/case-studies/helping-smes-grow-with-funding-and-business-support" },
    { govuk_page: "https://www.gov.uk/government/case-studies/hieta-lightweight-heat-recovery-technology-through-3d-printing" },
    { govuk_page: "https://www.gov.uk/government/case-studies/humaware-novel-prognostics-can-save-aircraft-maintenance-costs" },
    { govuk_page: "https://www.gov.uk/government/case-studies/iconichem-recycling-rare-materials-in-electric-vehicles" },
    { govuk_page: "https://www.gov.uk/government/case-studies/igeolise-races-to-its-destination-with-time-based-search" },
    { govuk_page: "https://www.gov.uk/government/case-studies/ilika-technologies-recharging-the-electric-vehicle-market" },
    { govuk_page: "https://www.gov.uk/government/case-studies/impression-technologies-firm-attracts-6-million-for-new-plant" },
    { govuk_page: "https://www.gov.uk/government/case-studies/improbable-digital-firm-raises-20-million-from-us-backers" },
    { govuk_page: "https://www.gov.uk/government/case-studies/inlecom-helping-european-businesses-to-work-more-efficiently" },
    { govuk_page: "https://www.gov.uk/government/case-studies/innovators-lead-the-way-in-hydrogen-fuel-cell-technology" },
    { govuk_page: "https://www.gov.uk/government/case-studies/interface-polymers-spin-out-set-to-transform-plastics-recycling" },
    { govuk_page: "https://www.gov.uk/government/case-studies/ionburst-safe-and-anonymous-data-in-the-cloud" },
    { govuk_page: "https://www.gov.uk/government/case-studies/irrigation-system-helps-farms-to-grow-more-crops-and-cut-energy" },
    { govuk_page: "https://www.gov.uk/government/case-studies/isansys-demand-grows-for-wireless-patient-monitoring-system" },
    { govuk_page: "https://www.gov.uk/government/case-studies/isansys-lifecare-transforming-the-way-we-keep-an-eye-on-patients" },
    { govuk_page: "https://www.gov.uk/government/case-studies/ktp-programme-helps-northern-ireland-generate-business-growth" },
    { govuk_page: "https://www.gov.uk/government/case-studies/led-sleep-mask-tackles-causes-of-sight-loss" },
    { govuk_page: "https://www.gov.uk/government/case-studies/london-architects-lead-the-way-in-sustainable-digital-design" },
    { govuk_page: "https://www.gov.uk/government/case-studies/loopwheels-delivering-a-smoother-ride-for-wheelchair-users" },
    { govuk_page: "https://www.gov.uk/government/case-studies/magma-leading-oil-companies-adopt-uk-developed-sub-sea-piping" },
    { govuk_page: "https://www.gov.uk/government/case-studies/mastodon-c-helping-big-cities-to-solve-planning-challenges" },
    { govuk_page: "https://www.gov.uk/government/case-studies/mech-tool-engineering-partnership-brings-savings-and-business" },
    { govuk_page: "https://www.gov.uk/government/case-studies/medherant-pioneering-drug-delivery-through-the-skin" },
    { govuk_page: "https://www.gov.uk/government/case-studies/mendeley-shares-scientific-research-to-build-a-better-future" },
    { govuk_page: "https://www.gov.uk/government/case-studies/micro-turbine-charger-boosts-market-appeal-of-electric-vehicles" },
    { govuk_page: "https://www.gov.uk/government/case-studies/microchip-firm-senses-opportunity-to-bridge-the-technology-gap" },
    { govuk_page: "https://www.gov.uk/government/case-studies/mobile-app-and-wristband-technology-transforms-epilepsy-care" },
    { govuk_page: "https://www.gov.uk/government/case-studies/molecular-warehouse-monitoring-transplant-patients-by-mobile" },
    { govuk_page: "https://www.gov.uk/government/case-studies/nanoco-developing-new-techniques-to-detect-and-treat-cancer" },
    { govuk_page: "https://www.gov.uk/government/case-studies/new-aston-martin-db11-features-uk-firms-low-carbon-innovation" },
    { govuk_page: "https://www.gov.uk/government/case-studies/north-east-manufacturers-thrive-on-knowledge-transfer-programmes" },
    { govuk_page: "https://www.gov.uk/government/case-studies/novel-hybrid-aircraft-prepares-to-resume-flight-test-programme" },
    { govuk_page: "https://www.gov.uk/government/case-studies/oaktec-helping-to-power-remote-populations" },
    { govuk_page: "https://www.gov.uk/government/case-studies/oxford-photovoltaics-a-shining-light-in-solar-cell-innovation" },
    { govuk_page: "https://www.gov.uk/government/case-studies/oxitec-business-accelerates-its-fight-against-dangerous-viruses" },
    { govuk_page: "https://www.gov.uk/government/case-studies/pab-coventry-new-metal-techniques-bring-big-rise-in-turnover" },
    { govuk_page: "https://www.gov.uk/government/case-studies/perpetuum-self-powered-rail-safety-technology-drives-jobs-growth" },
    { govuk_page: "https://www.gov.uk/government/case-studies/photocentric-next-gen-3d-printing-using-mobile-phone-screens" },
    { govuk_page: "https://www.gov.uk/government/case-studies/predictive-engine-health-check-can-avoid-costly-ship-breakdowns" },
    { govuk_page: "https://www.gov.uk/government/case-studies/promethean-nanoparticle-products-go-into-full-scale-production" },
    { govuk_page: "https://www.gov.uk/government/case-studies/pyrogenesys" },
    { govuk_page: "https://www.gov.uk/government/case-studies/qioptiq-82-million-contract-win-with-ministry-of-defence" },
    { govuk_page: "https://www.gov.uk/government/case-studies/randox-fighting-global-antimicrobial-resistance" },
    { govuk_page: "https://www.gov.uk/government/case-studies/rapita-systems-testing-new-safety-systems-for-cars-and-aircraft" },
    { govuk_page: "https://www.gov.uk/government/case-studies/red-ninja-business-transformed-after-taking-part-in-challenge" },
    { govuk_page: "https://www.gov.uk/government/case-studies/red-ninjas-smart-tech-clears-the-road-for-ambulance-crews" },
    { govuk_page: "https://www.gov.uk/government/case-studies/regenerative-medicine-a-new-therapy-for-stroke-patients" },
    { govuk_page: "https://www.gov.uk/government/case-studies/renovagen-rolls-out-lightweight-portable-solar-power" },
    { govuk_page: "https://www.gov.uk/government/case-studies/rezatec-leads-in-satellite-data-innovation" },
    { govuk_page: "https://www.gov.uk/government/case-studies/riversimple-the-electric-car-that-will-never-be-sold" },
    { govuk_page: "https://www.gov.uk/government/case-studies/sagetech-leading-sustainable-anaesthesia" },
    { govuk_page: "https://www.gov.uk/government/case-studies/saturn-bioponics-novel-growing-system-quadruples-crop-yield" },
    { govuk_page: "https://www.gov.uk/government/case-studies/saturn-bioponics-uk-success-just-the-start-for-3d-crop-grower" },
    { govuk_page: "https://www.gov.uk/government/case-studies/schizophrenia-treatment-funding-enables-next-stage-trials" },
    { govuk_page: "https://www.gov.uk/government/case-studies/self-powered-buildings-to-transform-energy-use" },
    { govuk_page: "https://www.gov.uk/government/case-studies/shadow-robot-a-helping-hand-to-achieve-independent-living" },
    { govuk_page: "https://www.gov.uk/government/case-studies/sigma-precision-saving-weight-for-aero-engine-manufacturers" },
    { govuk_page: "https://www.gov.uk/government/case-studies/signal-media-start-up-transformed-by-university-collaboration" },
    { govuk_page: "https://www.gov.uk/government/case-studies/snap-fashion-digital-business-revolutionising-the-way-we-shop" },
    { govuk_page: "https://www.gov.uk/government/case-studies/solar-powered-charger-connects-rural-villages-to-the-world" },
    { govuk_page: "https://www.gov.uk/government/case-studies/spin-out-gets-set-to-launch-finger-prick-diagnosis-for-anaemia" },
    { govuk_page: "https://www.gov.uk/government/case-studies/spin-out-sets-the-pace-with-real-time-running-style-retraining" },
    { govuk_page: "https://www.gov.uk/government/case-studies/stepjockey-health-app-developer-wins-600000-private-investment" },
    { govuk_page: "https://www.gov.uk/government/case-studies/success-story-f1-technology-finds-a-way-into-buses-and-diggers" },
    { govuk_page: "https://www.gov.uk/government/case-studies/success-story-nanoceramics-could-cut-uks-lighting-bill-by-20" },
    { govuk_page: "https://www.gov.uk/government/case-studies/success-story-novel-imaging-system-guides-surgeons-to-cancers" },
    { govuk_page: "https://www.gov.uk/government/case-studies/success-story-olympic-device-leads-to-blood-clot-prevention" },
    { govuk_page: "https://www.gov.uk/government/case-studies/sunamp-firm-takes-new-battery-technology-to-vehicle-market" },
    { govuk_page: "https://www.gov.uk/government/case-studies/swanbarton-empowering-communities-in-the-developing-world" },
    { govuk_page: "https://www.gov.uk/government/case-studies/synapse-connecting-business-spreadsheets-in-the-cloud" },
    { govuk_page: "https://www.gov.uk/government/case-studies/transvac-game-changing-technology-opens-2-billion-global-market" },
    { govuk_page: "https://www.gov.uk/government/case-studies/trialling-tomorrows-technology-today-businesses-show-the-way" },
    { govuk_page: "https://www.gov.uk/government/case-studies/uk-firms-find-european-partners-to-help-them-grow-in-new-markets" },
    { govuk_page: "https://www.gov.uk/government/case-studies/unlocking-the-potential-of-the-internet-of-things" },
    { govuk_page: "https://www.gov.uk/government/case-studies/upside-energy-balancing-peak-supply-and-demand-for-electricity" },
    { govuk_page: "https://www.gov.uk/government/collections/celebrating-success-sme-innovation-awards-2016" },
    { govuk_page: "https://www.gov.uk/government/collections/faraday-battery-challenge-industrial-strategy-challenge-fund" },
    { govuk_page: "https://www.gov.uk/government/collections/innovate-uk-case-studies" },
    { govuk_page: "https://www.gov.uk/government/publications/biomedical-catalyst-impact-evaluation" },
    { govuk_page: "https://www.gov.uk/government/publications/charm-impact-case-study" },
    { govuk_page: "https://www.gov.uk/government/publications/clean-and-affordable-energy-projects-address-the-challenge" },
    { govuk_page: "https://www.gov.uk/government/publications/collaboration-nation-digital-services-2010" },
    { govuk_page: "https://www.gov.uk/government/publications/collaboration-nation-high-value-manufacturing-2013" },
    { govuk_page: "https://www.gov.uk/government/publications/future-cities-uk-creating-better-places-to-live-work-and-play" },
    { govuk_page: "https://www.gov.uk/government/publications/icure-evaluation-of-pilot-programme" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-10-years-shaping-the-future" },
    { govuk_page: "https://www.gov.uk/government/publications/innovate-uk-aerospace-sme-case-studies" },
    { govuk_page: "https://www.gov.uk/government/publications/innovation-with-impact-50-companies-succeeding-with-innovate-uk" },
    { govuk_page: "https://www.gov.uk/government/publications/knowledge-transfer-partnerships-achievements-and-outcomes-2013-to-2014" },
    { govuk_page: "https://www.gov.uk/government/publications/london-and-cambridge-internet-of-things-directory-of-projects" },
    { govuk_page: "https://www.gov.uk/government/publications/low-and-zero-emission-vehicles-impact-review-2018" },
    { govuk_page: "https://www.gov.uk/government/publications/smart-funding-assessment-of-impact-and-evaluation-of-processes" },
    { govuk_page: "https://www.gov.uk/government/publications/the-economic-impact-on-the-uk-of-a-disruption-to-gnss" },
    { govuk_page: "https://www.gov.uk/government/publications/the-knowledge-transfer-partnership-programme-an-impact-review" },
    { govuk_page: "https://www.gov.uk/government/collections/horizon-2020-the-eu-research-and-innovation-funding-programme" },
    { govuk_page: "https://www.gov.uk/government/case-studies/power-roll-bringing-cheap-solar-power-to-africa-and-india" },
    { govuk_page: "https://www.gov.uk/government/publications/the-low-carbon-vehicles-innovation-platform-an-impact-review" },
  ]

  content_to_unpublish.each do |url|
    slug = URI.parse(url[:govuk_page]).path.split("/").last

    # Rebecca P's user id
    user = User.find(9929)

    published_edition = Document.find_by(slug: slug)&.published_edition

    unless published_edition
      puts "No published edition for GOV.UK page: #{url[:govuk_page]}"
      next
    end

    if (pre_pub_edition = published_edition.other_editions.in_pre_publication_state.first)
      edition_deleter = Whitehall.edition_services.deleter(pre_pub_edition)

      if edition_deleter.perform!
        puts "Draft deleted with URL: #{url[:govuk_page]}"
      else
        puts edition_deleter.failure_reason
      end
    end

    unpublishing_params = {
      redirect: false,
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
      explanation: "This content has been archived, as Innovate UK are now part of UKRI. For the latest information from Innovate UK, please visit the [Innovate UK council page](https://www.ukri.org/councils/innovate-uk/) on the UKRI website.",
    }

    edition_unpublisher = Whitehall.edition_services.unpublisher(
      published_edition, user: user, remark: "Reset to draft", unpublishing: unpublishing_params
    )

    if edition_unpublisher.perform!
      puts "unpublished the page: #{url[:govuk_page]}"
    else
      puts edition_unpublisher.failure_reason
    end
  end
end
