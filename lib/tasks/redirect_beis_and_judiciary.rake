desc "Temp rake task to bulk consolidate beis & judiciary content"
task consolidate_beis_and_judiciary: :environment do
  beis_redirects = [
    { govuk_page: "https://www.gov.uk/government/publications/automatic-monitoring-and-targeting-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/automatic-monitoring-targeting-amt/automatic-monitoring-targeting-amt-sub-metering-systems" },
    { govuk_page: "https://www.gov.uk/government/publications/portable-energy-monitoring-equipment-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/automatic-monitoring-targeting-amt/portable-energy-monitoring-equipment" },
    { govuk_page: "https://www.gov.uk/government/publications/biomass-boilers-and-roomheaters-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-equipment/biomass-boilers" },
    { govuk_page: "https://www.gov.uk/government/publications/gas-fired-condensing-water-heaters-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-equipment/gas-fired-condensing-water-heaters" },
    { govuk_page: "https://www.gov.uk/government/publications/hot-water-boilers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-equipment/hot-water-boilers" },
    { govuk_page: "https://www.gov.uk/government/publications/steam-boilers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-equipment/steam-boilers" },
    { govuk_page: "https://www.gov.uk/government/publications/burners-with-controls-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-retrofit-equipment/burner-controls" },
    { govuk_page: "https://www.gov.uk/government/publications/condensating-economisers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-retrofit-equipment/condensing-economisers" },
    { govuk_page: "https://www.gov.uk/government/publications/heat-recovery-equipment-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-retrofit-equipment/heat-recovery-flash-steam-and-boiler-blowdown-condensate" },
    { govuk_page: "https://www.gov.uk/government/publications/flue-gas-economisers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-retrofit-equipment/non-condensing-economisers" },
    { govuk_page: "https://www.gov.uk/government/publications/retrofit-burner-control-systems-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/boiler-retrofit-equipment/retrofit-burner-control-systems" },
    { govuk_page: "https://www.gov.uk/government/publications/combined-heat-and-power-chp-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/combined-heat-power-chp" },
    { govuk_page: "https://www.gov.uk/government/publications/desiccant-air-dryers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/compressed-air-equipment/desiccant-air-dryers-energy-saving-controls" },
    { govuk_page: "https://www.gov.uk/government/publications/master-controllers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/compressed-air-equipment/master-controllers" },
    { govuk_page: "https://www.gov.uk/government/publications/refrigerated-air-dryer-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/compressed-air-equipment/refrigerated-air-dryers-energy-saving-controls" },
    { govuk_page: "https://www.gov.uk/government/publications/air-source-gas-engine-driven-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/air-source-gas-engine-driven-split-and-multi-split-including-vrf-heat-pumps" },
    { govuk_page: "https://www.gov.uk/government/publications/air-source-packaged-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/packaged-air-air-heat-pumps-rooftop" },
    { govuk_page: "https://www.gov.uk/government/publications/air-source-split-and-multi-split-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/air-air-heat-pumps-split-multi-split-and-vrf" },
    { govuk_page: "https://www.gov.uk/government/publications/air-to-water-heat-pumps-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/air-water-heat-pumps" },
    { govuk_page: "https://www.gov.uk/government/publications/ground-source-brine-to-water-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/water-or-brine-water-heat-pumps" },
    { govuk_page: "https://www.gov.uk/government/publications/heat-pump-dehumidifiers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/heat-pump-dehumidifiers" },
    { govuk_page: "https://www.gov.uk/government/publications/heat-pump-driven-air-curtains-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/heat-pump-driven-air-curtains" },
    { govuk_page: "https://www.gov.uk/government/publications/co2-heat-pumps-for-domestic-hot-water-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/air-domestic-hot-water-heat-pumps" },
    { govuk_page: "https://www.gov.uk/government/publications/water-source-split-and-multi-split-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-pumps/water-air-heat-pumps-split-multi-split-and-vrf" },
    { govuk_page: "https://www.gov.uk/government/publications/air-to-air-energy-recovery-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heat-recovery-ventilation-units/heat-recovery-ventilation-units" },
    { govuk_page: "https://www.gov.uk/government/publications/active-chilled-beams-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heating-ventilation-air-conditioning-hvac/active-chilled-beams" },
    { govuk_page: "https://www.gov.uk/government/publications/close-control-air-conditioning-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heating-ventilation-air-conditioning-hvac/close-control-air-conditioning-equipment" },
    { govuk_page: "https://www.gov.uk/government/publications/building-environment-zone-controls-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heating-ventilation-air-conditioning-hvac/hvac-building-controls" },
    { govuk_page: "https://www.gov.uk/government/publications/evaporative-air-coolers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/heating-ventilation-air-conditioning-hvac/evaporative-air-coolers" },
    { govuk_page: "https://www.gov.uk/government/publications/high-speed-hand-air-dryers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/high-speed-hand-air-dryers" },
    { govuk_page: "https://www.gov.uk/government/publications/lighting-controls-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/lighting/lighting-controls" },
    { govuk_page: "https://www.gov.uk/government/publications/white-led-lighting-modules-for-backlit-illuminated-signs-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/lighting/white-led-lighting-modules-backlit-illuminated-signs" },
    { govuk_page: "https://www.gov.uk/government/publications/efficient-white-lighting-units-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/lighting/efficient-white-lighting-units" },
    { govuk_page: "https://www.gov.uk/government/publications/permanent-magnet-synchronous-motors", target_url: "https://etl.beis.gov.uk/products/motors-drives/converter-fed-motors" },
    { govuk_page: "https://www.gov.uk/government/publications/single-speed-induction-motors-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/motors-drives/line-operated-ac-motors" },
    { govuk_page: "https://www.gov.uk/government/publications/variable-speed-drives-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/motors-drives/variable-speed-drives" },
    { govuk_page: "https://www.gov.uk/government/publications/pipework-insulation-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/pipework-insulation/pipework-insulation" },
    { govuk_page: "https://www.gov.uk/government/publications/radiant-heating-equipment-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/radiant-warm-air-heaters/radiant-heating-equipment" },
    { govuk_page: "https://www.gov.uk/government/publications/packaged-warm-air-heaters-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/radiant-warm-air-heaters/warm-air-heating-equipment" },
    { govuk_page: "https://www.gov.uk/government/publications/absorption-cooling-and-heat-driven-equipment-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/absorption-other-heat-driven-cooling-heating-equipment" },
    { govuk_page: "https://www.gov.uk/government/publications/air-blast-coolers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/air-blast-coolers" },
    { govuk_page: "https://www.gov.uk/government/publications/air-cooled-condensing-units-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/air-cooled-condensing-units" },
    { govuk_page: "https://www.gov.uk/government/publications/automated-refrigerant-leak-detection-systems-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/automated-permanent-refrigerant-leak-detection-systems" },
    { govuk_page: "https://www.gov.uk/government/publications/covers-for-refrigerated-display-cabinets-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/curtains-blinds-doors-and-covers-refrigerated-display-cabinets" },
    { govuk_page: "https://www.gov.uk/government/publications/evaporative-condensers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/evaporative-condensers" },
    { govuk_page: "https://www.gov.uk/government/publications/packaged-chillers-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/packaged-chillers" },
    { govuk_page: "https://www.gov.uk/government/publications/professional-refrigerated-storage-cabinets-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/professional-refrigerated-storage-cabinets" },
    { govuk_page: "https://www.gov.uk/government/publications/refrigerated-display-cabinets-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/refrigerated-display-cabinets" },
    { govuk_page: "https://www.gov.uk/government/publications/refrigeration-compressors-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/refrigeration-compressors" },
    { govuk_page: "https://www.gov.uk/government/publications/refrigeration-system-controls-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/refrigeration-system-controls" },
    { govuk_page: "https://www.gov.uk/government/publications/solar-thermal-systems-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/solar-thermal-systems-collectors/solar-thermal-collectors" },
    { govuk_page: "https://www.gov.uk/government/publications/uninterruptible-power-supplies-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/uninterruptible-power-supplies/uninterruptible-power-supplies" },
    { govuk_page: "https://www.gov.uk/government/publications/waste-heat-to-electricity-conversion-equipment", target_url: "https://etl.beis.gov.uk/products/waste-heat-electricity-conversion-equipment/organic-rankine-cycle-heat-recovery-equipment" },
    { govuk_page: "https://www.gov.uk/government/publications/saturated-steam-to-electricity-conversion-equipment-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/waste-heat-electricity-conversion-equipment/saturated-steam-electricity-conversion-equipment" },
    { govuk_page: "https://www.gov.uk/government/publications/cellar-cooling-equpiment-criteria-for-etl-inclusion", target_url: "https://etl.beis.gov.uk/products/refrigeration-equipment/cellar-cooling-equipment" },
  ]

  judiciary_redirects = [
    { govuk_page: "https://www.gov.uk/government/publications/senior-courts-costs-office-guide", target_url: "https://www.judiciary.uk/announcements/senior-courts-costs-office-guide-the-2021-version-is-now-available" },
    { govuk_page: "https://www.gov.uk/government/publications/queens-bench-guide", target_url: "https://www.judiciary.uk/publications/the-queens-bench-guide-2021" },
  ]

  (judiciary_redirects + beis_redirects).each do |redirect|
    slug = URI.parse(redirect[:govuk_page]).path.split("/").last

    # Peter H
    user = User.find(8627)

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
