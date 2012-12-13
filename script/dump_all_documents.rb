require 'csv'
require 'ostruct'
include Rails.application.routes.url_helpers, PublicDocumentRoutesHelper, Admin::EditionRoutesHelper

mysql_slave_config = ActiveRecord::Base.configurations['production'].merge('host' => 'slave.mysql')
ActiveRecord::Base.establish_connection(mysql_slave_config)

module PublicDocumentRoutesHelper
  def request
    OpenStruct.new(host: "whitehall.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk")
  end
end

CSV.open(Rails.root.join('public/government/new_document_mappings.csv'), 'wb') do |csv_out|

  csv_out << ['Old Url','New Url','Status','Whole Tag','Slug','Admin Url','State']
  Document.all.each do |document|
    edition = document.published_edition || document.latest_edition
    if edition
      status = (edition.state == 'published' ? '301' : '')
      whole_tag = (edition.state == 'published' ? 'Closed' : 'Open')
      csv_out << [document.document_sources.any? ? document.document_sources.first.url : '', public_document_url(edition, protocol: 'https'), status, whole_tag, document.slug, admin_edition_url(edition, host: "whitehall-admin.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk", protocol: 'https'), edition.state]
    else
      csv_out << [document.document_sources.any? ? document.document_sources.first.url : '' , '', '', 'Open']
    end
  end

  host_name = (ENV['FACTER_govuk_platform'] == 'production' ? 'https://www.gov.uk' : 'https://www.preview.alphagov.co.uk')
  AttachmentSource.all.each do |attachment_source|
    attachment_url = attachment_source.attachment ? host_name + attachment_source.attachment.url : ""
    status = (attachment_url.blank? ? '' : '301')
    whole_tag = (attachment_url.blank? ? 'Open' : 'Closed')
    csv_out << [attachment_source.url, attachment_url, status, whole_tag]
  end

end
