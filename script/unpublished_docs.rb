# Says Robin: "I'd like to request a data dump of all docs converted
# to draft and not yet published, with first_published dates attached,
# so that we can be sure to action a date cleanup before force
# publishing any further docs."
# This is to prevent further "no date, in draft after import"
# publishing errors.

require 'csv'
require 'ostruct'

admin_host = "whitehall-admin.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk"
host_name = (ENV['FACTER_govuk_platform'] == 'production' ? 'www.gov.uk' : 'www.preview.alphagov.co.uk')
protocol = (ENV['FACTER_govuk_platform'] == 'development' ? 'http': 'https')

def url_maker
  @url_maker ||= Whitehall::UrlMaker.new
end

out = CSV.generate do |csv|
  csv << ['Title', 'Type', 'First Published', 'Admin URL']
  Edition.where(state: :draft).each do |doc|
    csv << [doc.title, doc.class, doc.first_public_at, url_maker.admin_edition_url(doc, host: admin_host, protocol: protocol)]
  end
end

puts out
