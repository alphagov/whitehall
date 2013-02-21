require 'csv'
require 'ostruct'
include Rails.application.routes.url_helpers, PublicDocumentRoutesHelper, Admin::EditionRoutesHelper

ENV['FACTER_govuk_platform'] ||= "production"

if ENV['FACTER_govuk_platform'] == 'production'
  mysql_slave_config = ActiveRecord::Base.configurations['production'].merge('host' => 'slave.mysql')
  ActiveRecord::Base.establish_connection(mysql_slave_config)
end

module PublicDocumentRoutesHelper
  def request
    OpenStruct.new(host: "whitehall.#{ENV['FACTER_govuk_platform']}.alphagov.co.uk")
  end
end

def row(public_url, admin_url)
  [
    '',
    public_url,
    '',
    '',
    '',
    admin_url,
    ''
  ]
end

exporter = Whitehall::Exporters::DocumentMappings.new(ENV['FACTER_govuk_platform'])

CSV.open(Rails.root.join('public/government/all_document_attachment_and_non_document_mappings.csv'), 'wb') do |csv_out|
  exporter.export(csv_out)
end
