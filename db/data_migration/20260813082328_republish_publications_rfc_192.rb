def migrate
  invalid_publication_base_paths.each do |invalid_publication_base_path|
    old_slug = invalid_publication_base_path.split("/").last
    matching_editions = Edition.published.where(slug: old_slug)

    if matching_editions.count.zero? || matching_editions.count > 1
      puts("ERROR couldn't find exactly 1 published edition for #{old_slug}")
    else
      ed = matching_editions.first
      ed.slug_override = fixed_slug(old_slug)
      puts("Altering #{old_slug} to #{ed.slug_override}")
      validator = GdsApi::Validators::BasePathValidator.new("/#{ed.slug_override}")
      puts("WARNING: RFC-192 validation failed! #{validator.errors}") unless validator.valid?
      puts("WARNING: Unable to save! #{ed.errors.to_a.join}") unless valid_except_slug?(ed)
      if validator.valid? && valid_except_slug?(ed)
        ed.save!(validate: false)
        PublishingApiDocumentRepublishingJob.new.perform(ed.document.id)
      end
    end
  end
end

def valid_except_slug?(edition)
  edition.valid? # Trigger validations
  return true if edition.errors.attribute_names == [:slug_override]

  edition.valid?
end

def fixed_slug(old_slug)
  old_slug.downcase.gsub("_", "-")
end

def invalid_publication_base_paths
  [
    "/government/publications/FSE-confirmation-of-receipt-of-application",
    "/government/publications/201516-prosperity-fund-korea-programme_2nd-round-project-concept-form",
    "/government/publications/201516-prosperity-fund-korea-programme_2nd-round-grant-contract",
    "/government/publications/201516-prosperity-fund-korea-programme_2nd-round-guidance-for-implementers",
    "/government/publications/environmental-impact-assessment-scope-and-methodology-report-part-3-of-3-ct-001-00001_part-3",
    "/government/publications/ma08-historic-environment-baseline-report-part-1-of-5-bid-he-001-0ma08_part-1",
    "/government/publications/ecological-baseline-data-amphibian-and-pond-and-canal-surveys-part-2-of-2-bid-ec-007-00001_part-2",
    "/government/publications/ecological-baseline-data-bats-part-2-of-2-bid-ec-011-00001_part-2",
    "/government/publications/ma06-historic-environment-baseline-report-part-1-of-2-bid-he-001-0ma06_part-1",
    "/government/publications/off-route-works-carlisle-station-historic-environment-baseline-report-part-1-of-2-bid-he-001-or002_part-1",
    "/government/publications/transport-assessment-annexes-b-g-report-2-of-2-tr-005-00000_report-2",
    "/government/publications/ma06ma07ma08-transport-assessment-part-2-report-2-of-3-tr-002-00006_report-2",
    "/government/publications/ma06ma07ma08-transport-assessment-part-2-report-2-of-3-tr-002-00006_report-2--2",
    "/government/publications/planning-data-part-3-of-3-ct-004-00000_part-3",
    "/government/publications/ma06ma07ma08-transport-assessment-part-2-report-3-of-3-tr-002-00006_report-3",
    "/government/publications/ma07-historic-environment-baseline-report-part-2-of-2-bid-he-001-0ma07_part-2",
    "/government/publications/east-anglia-ea10a_b_c-approaches-to-lowestoft-2024",
    "/government/publications/16-prosperity-fund-korea-programme_2nd-round-full-bidding-form",
    "/government/publications/ma06-historic-environment-baseline-report-part-2-of-2-bid-he-001-0ma06_part-2",
    "/government/publications/water-framework-directive-compliance-assessment-baseline-data-part-2-of-2-bid-wr-002-00001_part-2",
    "/government/publications/ma06ma07ma08-transport-assessment-part-3-report-1-of-4-tr-003-00006_report-1",
    "/government/publications/ma07-transport-assessment-part-2-report-1-of-3-tr-002-00006_report-1",
    "/government/publications/ma07-historic-environment-baseline-report-part-1-of-2-bid-he-001-0ma07_part-1",
    "/government/publications/ma06ma07ma08-transport-assessment-part-3-report-3-of-4-tr-003-00006_report-3",
    "/government/publications/ecological-baseline-data-amphibian-and-pond-and-canal-surveys-part-1-of-2-bid-ec-007-00001_part-1",
    "/government/publications/water-framework-directive-compliance-assessment-part-1-of-2-wr-001-00000_part-1",
    "/government/publications/ma08-historic-environment-baseline-report-part-5-of-5-bid-he-001-0ma08_part-5",
    "/government/publications/ma08-historic-environment-baseline-report-part-2-of-5-bid-he-001-0ma08_part-2",
    "/government/publications/ma01-historic-environment-baseline-report-part-2-of-2-bid-he-001-0ma01_part-2",
    "/government/publications/ma06ma07-ma08-transport-assessment-part-2-report-1-of-3-tr-002-00006_report-1",
    "/government/publications/water-framework-directive-compliance-assessment-part-2-of-2-wr-001-00000_part-2",
    "/government/publications/defra_spend_on_stationery",
    "/government/publications/ma08-historic-environment-baseline-report-part-3-of-5-bid-he-001-0ma08_part-3--2",
    "/government/publications/201516-prosperity-fund-programme-strategy_2nd-round",
    "/government/publications/msn-1867-m-uk-requirements-for-the-recognition-of-non-uk-certification-leading-to-the-issue-of-a-FSE",
    "/government/publications/ecological-baseline-data-bats-part-1-of-2-bid-ec-011-00001_part-1",
    "/government/publications/ma06ma07ma08-transport-assessment-part-3-report-2-of-4-tr-003-00006_report-2",
    "/government/publications/planning-data-part-1-of-3-ct-004-00000_part-1",
    "/government/publications/off-route-works-carlisle-station-historic-environment-baseline-report-part-2-of-2-bid-he-001-or002_part-2",
    "/government/publications/APRHAI-annual-reports",
    "/government/publications/ma02-historic-environment-baseline-report-part-2-of-2-bid-he-001-0ma02_part-2",
    "/government/publications/ma06ma07ma08-transport-assessment-part-2-report-1-of-3-tr-002-00006_report-1",
    "/government/publications/ma04-historic-environment-baseline-report-part-2-of-2-bid-he-001-0ma04_part-2",
    "/government/publications/water-framework-directive-compliance-assessment-baseline-data-part-1-of-2-bid-wr-002-00001_part-1",
    "/government/publications/environmental-impact-assessment-scope-and-methodology-report-part-1-of-3-ct-001-00001_part-1",
    "/government/publications/ma06ma07ma08-transport-assessment-part-3-report-4-of-4-tr-003-00006_report-4",
    "/government/publications/ma02-historic-environment-baseline-report-part-1-of-2-bid-he-001-0ma02_part-1",
    "/government/publications/ma08-historic-environment-baseline-report-part-3-of-5-bid-he-001-0ma08_part-3",
    "/government/publications/ma08-historic-environment-baseline-report-part-4-of-5-bid-he-001-0ma08_part-4",
    "/government/publications/environmental-impact-assessment-scope-and-methodology-report-part-2-of-3-ct-001-00001_part-2",
    "/government/publications/transport-assessment-part-4-and-annex-a-report-1-of-2-tr-005-00000_report-1",
    "/government/publications/ma04-historic-environment-baseline-report-part-1-of-2-bid-he-001-0ma04_part-1",
    "/government/publications/ma01-historic-environment-baseline-report-part-1-of-2-bid-he-001-0ma01_part-1",
    "/government/publications/accessing-government-secured-flu-vaccines-guidance-for-primary-care-in-England-for-2021-to-2022",
    "/government/publications/planning-data-part-2-of-3-ct-004-00000_part-2",
    "/government/publications/communiques-from-the-interministerial-group-for-education-January-2022-to-June-2023",
  ]
end

migrate
