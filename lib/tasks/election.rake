namespace :election do
  desc "Republishes all case studies to the Publishing API"
  task :republish_case_studies => :environment do
    require 'data_hygiene/publishing_api_republisher'

    DataHygiene::PublishingApiRepublisher.new(CaseStudy.published).perform
  end
end
