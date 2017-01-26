# These documents all have 'submitted' editions (drafts ready for publication) with
# an unpublishing with an alt url, so they are missing the relevant redirect in
# the content store.
# Fixes this by creating the redirect.
redirects = {
  "5e37b44e-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/indicator-methodology-notes",
  "5e5f8f40-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/afprb-report-number-42-and-dms-supplement-2013",
  "5f1aabbc-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/sfa-financial-assurance-joint-audit-code-of-practice",
  "5ec00621-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/ins216-how-to-apply-for-free-disabled-tax",
  "5dbbdcf5-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/v3554-application-for-first-vehicle-tax-and-registration-of-a-new-motor-vehicle-v554",
  "5dbbe107-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/v3555-application-for-first-vehicle-tax-and-registration-of-a-used-motor-vehicle-v555",
  "5e16a565-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/application-for-vehicle-tax-v10",
  "5fe5ea26-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/river-thames-unpowered-boat-application-form",
  "5e16a35d-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/application-to-change-a-vehicle-tax-v70",
  "60551b7e-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/driver-and-vehicle-licensing-agency-civil-service-people-survey",
  "5e2effd4-7631-11e4-a3cb-005056011aef" => "https://www.gov.uk/government/publications/assessing-fitness-to-drive-a-guide-for-medical-professionals",
}

redirects.each do |content_id, url|
  PublishingApiRedirectWorker.perform_async(content_id, url, :en, true)
end
