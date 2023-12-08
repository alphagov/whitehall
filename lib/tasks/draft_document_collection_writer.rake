require_relative "../../app/validators/gov_uk_url_validator"

desc "Create a draft document collection in the whitehall database, from a given specialist topic"
task :create_draft_document_collection, %i[specialist_topic_base_path assignee_email_address] => :environment do |_task, args|
  message = "Error! A specialist topic base_path and valid email address are required"
  raise message unless args[:specialist_topic_base_path].present? && args[:assignee_email_address].present?

  puts "Fetching specialist topic at #{args[:specialist_topic_base_path]}"
  topic = SpecialistTopicFetcher.call(args[:specialist_topic_base_path])

  puts "Creating draft document collection"
  builder = DraftDocumentCollectionBuilder.new(topic, args[:assignee_email_address])
  builder.perform!

  puts builder.message
end

desc "Create draft document collections in the whitehall database for all HRMC owned specialist topics"
task convert_hmrc_specialist_topics: :environment do
  hmrc_specialist_topic_paths = [
    "/topic/benefits-credits/child-benefit",
    "/topic/benefits-credits/tax-credits",
    "/topic/business-tax/aggregates-levy",
    "/topic/business-tax/air-passenger-duty",
    "/topic/business-tax/alcohol-duties",
    "/topic/business-tax/capital-allowances",
    "/topic/business-tax/climate-change-levy",
    "/topic/business-tax/construction-industry-scheme",
    "/topic/business-tax/corporation-tax",
    "/topic/business-tax/digital-services-tax",
    "/topic/business-tax/employment-related-securities",
    "/topic/business-tax/fuel-duty",
    "/topic/business-tax/gambling-duties",
    "/topic/business-tax/import-export",
    "/topic/business-tax/insurance-premium-tax",
    "/topic/business-tax/investment-schemes",
    "/topic/business-tax/ir35",
    "/topic/business-tax/landfill-tax",
    "/topic/business-tax/large-midsize-business-guidance",
    "/topic/business-tax/money-laundering-regulations",
    "/topic/business-tax/paye",
    "/topic/business-tax/pension-scheme-administration",
    "/topic/business-tax/self-employed",
    "/topic/business-tax/soft-drinks-industry-levy",
    "/topic/business-tax/stamp-duty-on-shares",
    "/topic/business-tax/stamp-taxes",
    "/topic/business-tax/tobacco-products-duty",
    "/topic/business-tax/vat",
    "/topic/community-organisations/community-amateur-sports-clubs",
    "/topic/dealing-with-hmrc/complaints-appeals",
    "/topic/dealing-with-hmrc/paying-hmrc",
    "/topic/dealing-with-hmrc/phishing-scams",
    "/topic/dealing-with-hmrc/software-development",
    "/topic/dealing-with-hmrc/tax-agent-guidance",
    "/topic/dealing-with-hmrc/tax-avoidance",
    "/topic/dealing-with-hmrc/tax-compliance",
    "/topic/oil-and-gas/finance-and-taxation",
    "/topic/personal-tax/capital-gains-tax",
    "/topic/personal-tax/coming-to-uk",
    "/topic/personal-tax/income-tax",
    "/topic/personal-tax/inheritance-tax",
    "/topic/personal-tax/leaving-uk",
    "/topic/personal-tax/living-working-abroad-offshore",
    "/topic/personal-tax/national-insurance",
    "/topic/personal-tax/non-resident-landlord-scheme",
    "/topic/personal-tax/savings-investment-tax",
    "/topic/personal-tax/self-assessment",
    "/topic/personal-tax/trusts",
  ]
  assigned_gds_content_designer = "kati.tirbhowan@digital.cabinet-office.gov.uk"
  hmrc_specialist_topic_paths.each do |path|
    Rake::Task["create_draft_document_collection"].invoke(path, assigned_gds_content_designer)
    Rake::Task["create_draft_document_collection"].reenable
  end
end
