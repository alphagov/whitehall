require 'csv'
require 'admin/edition_routes_helper'

module GiveAllDocumentsALeadOrganisationHelper
  ADMIN_HOST = 'whitehall-admin.production.alphagov.co.uk'

  def self.routes_helper
    @routes_helper ||= Whitehall::UrlMaker.new(host: GiveAllDocumentsALeadOrganisationHelper::ADMIN_HOST)
  end
end

count = successes = errors = more_orgs = 0
puts ['Result', 'ID', 'Title', 'URL'].to_csv
Edition.find_each do |edition|
  if edition.lead_organisations.empty?
    edition_organisation = edition.edition_organisations.first
    if edition_organisation.present?
      edition_organisation.lead = true
      edition_organisation.lead_ordering = 1
      edition_organisation.save
    end
  end
  edition.reload
  edition.valid?
  out = [edition.id, edition.title, GiveAllDocumentsALeadOrganisationHelper.routes_helper.admin_edition_url(edition)]
  state = nil
  if edition.errors[:lead_organisations].empty?
    if edition.organisations.count > 1
      more_orgs += 1
      state = 'MORE_ORGS'
    else
      successes += 1
      state = 'SUCCESS'
    end
  else
    errors += 1
    state = 'ERROR'
  end
  if ENV['VERBOSE']
    puts out.unshift(state).to_csv
  elsif state != 'SUCCESS'
    puts out.unshift(state).to_csv
  end
  count += 1
end

puts ["Count: #{count}", "More than one org: #{more_orgs}", "Success: #{successes}", "Errors: #{errors}"].to_csv
