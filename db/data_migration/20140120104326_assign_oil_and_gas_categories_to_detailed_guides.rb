def oil_and_gas_content
  {
    "carbon-capture-and-storage" => [
      "oil-and-gas-licensing-for-carbon-storage--3",
      "uk-carbon-capture-and-storage-government-funding-and-support",
      "oil-and-gas-carbon-storage-public-register",
    ],
    "environment-reporting-and-regulation" => [
      "oil-and-gas-eems-database",
      "oil-and-gas-environmental-alerts-and-incident-reporting",
      "oil-and-gas-environmental-data",
      "oil-and-gas-environmental-policy",
      "oil-and-gas-legislation-on-emissions-and-releases",
      "oil-and-gas-offshore-emergency-response-legislation",
      "oil-and-gas-offshore-environmental-legislation",
      "oil-and-gas-ospar-ems-recommendation",
      "oil-and-gas-decc-public-registers-of-enforcement-activity",
      "oil-and-gas-uk-oil-portal",
    ],
    "exploration-and-production" => [
      "oil-and-gas-decc-public-registers-of-enforcement-activity",
      "oil-and-gas-uk-oil-portal",
      "oil-and-gas-codes-of-practice",
      "oil-and-gas-digital-data-exchange-format",
      "oil-and-gas-fallow-blocks-and-discoveries",
      "oil-and-gas-measurement-of-petroleum",
      "oil-and-gas-operatorship",
      "oil-and-gas-petroleum-operations-notices",
      "oil-and-gas-review-of-uk-offshore-oil-and-gas-recovery",
      "oil-and-gas-fields-and-field-development",
      "oil-and-gas-geoscientific-data",
      "oil-and-gas-uk-field-data",
      "oil-and-gas-wells",
      "oil-and-gas-offshore-maps-and-gis-shapefiles",
      "oil-and-gas-onshore-maps-and-gis-shapefiles",
      "oil-and-gas-onshore-exploration-and-production",
    ],
    "fields-and-wells" => [
      "oil-and-gas-fields-and-field-development",
      "oil-and-gas-geoscientific-data",
      "oil-and-gas-uk-field-data",
      "oil-and-gas-wells",
    ],
    "finance-and-taxation" => [
      "extractive-industries-transparency-initiative",
      "oil-and-gas-charging-regime-for-licensing-exploration-and-development",
      "oil-and-gas-taxation",
    ],
    "infrastructure-and-decommissioning" => [
      "oil-and-gas-decommissioning-of-offshore-installations-and-pipelines",
      "oil-and-gas-infrastructure",
      "oil-and-gas-project-pathfinder",
    ],
    "licensing" => [
      "oil-and-gas-carbon-storage-public-register",
      "oil-and-gas-decc-public-registers-of-enforcement-activity",
      "oil-and-gas-wells",
      "oil-and-gas-offshore-maps-and-gis-shapefiles",
      "oil-and-gas-onshore-maps-and-gis-shapefiles",
      "offshore-energy-strategic-environmental-assessment-sea-an-overview-of-the-sea-process",
      "oil-and-gas-licence-data",
      "oil-and-gas-licence-relinquishments",
      "oil-and-gas-licensing-rounds",
      "oil-and-gas-licensing-for-gas-storage-and-unloading",
      "oil-and-gas-petroleum-licensing-guidance",
      "oil-and-gas-uk-oil-portal",
    ],
    "onshore-oil-and-gas" => [
      "oil-and-gas-onshore-maps-and-gis-shapefiles",
      "oil-and-gas-onshore-exploration-and-production",
    ]
  }
end

class ValidationSkippingPublisher < EditionForcePublisher
  def failure_reason
    nil
  end

private
  def fire_transition!
    edition.force_publish
    edition.force_published = false
    edition.save(validate: false)
    supersede_previous_editions!
  end
end


logger = Logger.new(STDOUT)

gds_user = User.find_by_name!('GDS Inside Government Team')
Edition::AuditTrail.whodunnit = gds_user

logger.info "Assigning detailed guide categories"

oil_and_gas_content.each do |category, content|
  full_category_slug = "industry-sector-oil-and-gas-#{category}"
  logger.info "--> #{full_category_slug}"

  category = MainstreamCategory.find_by_slug(full_category_slug)

  unless category.present?
    logger.info "\tCategory could not be found"
    next
  end
  logger.info "\tCategory found: #{category.title}"

  content.each do |slug|
    detailed_guide = Document.at_slug("DetailedGuide", slug)
    logger.info "\t--> detailed guide #{slug}"

    unless detailed_guide.present?
      logger.info "\t\tNo detailed guide found with slug #{slug}: skipping."
      next
    end
    logger.info "\t\tDetailed guide found."

    if detailed_guide.published_edition.is_latest_edition?
      edition = detailed_guide.published_edition.create_draft(gds_user)

      edition.other_mainstream_categories << category
      edition.minor_change = true

      publisher = ValidationSkippingPublisher.new(edition)
      publisher.perform!

      logger.info "\t\tPublished new detailed guide edition: #{edition.id}"
    else
      edition = detailed_guide.latest_edition

      edition.other_mainstream_categories << category
      edition.save

      logger.info "\t\tUpdated existing detailed guide edition: #{edition.id}"
    end

    edition.editorial_remarks.create!(
      body: "This change assigns a new category to this detailed guide - #{category.title}.",
      author: gds_user
    )
    logger.info "\t\tCreated editorial remark on edition"
  end
end

logger.info "Oil and gas content migration complete"
