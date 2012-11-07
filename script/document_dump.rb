require 'csv'
require 'ostruct'
include Rails.application.routes.url_helpers, PublicDocumentRoutesHelper, Admin::EditionRoutesHelper

mysql_slave_config = ActiveRecord::Base.configurations['production'].merge('host' => 'slave.mysql')
ActiveRecord::Base.establish_connection(mysql_slave_config)

module PublicDocumentRoutesHelper; def request; OpenStruct.new(:host => "whitehall.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk"); end; end

CSV do |csv_out|

  csv_out << %w(source target slug admin state)
  Document.joins(:document_source).all.each do |document|
    edition = document.published_edition || document.latest_edition
    next unless edition
    csv_out << [document.document_source.url, public_document_url(edition, :protocol => 'https'), document.slug, admin_edition_url(edition, :host => "whitehall-admin.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk", :protocol => 'https'), edition.state]
  end

  host_name = (ENV['FACTER_govuk_platform'] == 'production' ? 'https://www.gov.uk' : 'https://www.preview.alphagov.co.uk')
  AttachmentSource.all.each do |attachment_source|
    attachment_url = attachment_source.attachment ? host_name + attachment_source.attachment.url : ""
    csv_out << [attachment_source.url, attachment_url]
  end

end