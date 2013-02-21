require 'csv'
require 'ostruct'

ENV['FACTER_govuk_platform'] ||= "production"

if ENV['FACTER_govuk_platform'] == 'production'
  mysql_slave_config = ActiveRecord::Base.configurations['production'].merge('host' => 'slave.mysql')
  ActiveRecord::Base.establish_connection(mysql_slave_config)
end

exporter = Whitehall::Exporters::DocumentMappings.new(ENV['FACTER_govuk_platform'])

CSV.open(Rails.root.join('public/government/all_document_attachment_and_non_document_mappings.csv'), 'wb') do |csv_out|
  exporter.export(csv_out)
end
