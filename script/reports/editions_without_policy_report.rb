APP_PATH = File.expand_path('../../../config/application',  __FILE__)
require File.expand_path('../../../config/boot',  __FILE__)
require File.expand_path('../../../config/environment',  __FILE__)

require 'csv'
class EditionsWithoutPolicyReport
  attr_reader :output_file

  def initialize(output_file)
    @output_file = output_file
    @organisations = {}
  end

  def url_maker
    Whitehall.url_maker
  end

  def column_headings
    [
      'Type',
      'Public URL',
      'Admin URL',
      'First Lead Org',
      'First published at',
      'Publication Date',
      'Public timestamp',
      'Major change published at',
      'Updated at',
      'Delivered on'
    ]
  end

  def run!
    CSV.open(output_file, "w:utf-8") do |csv|
      puts "Writing to '#{output_file}'..."
      csv << column_headings

      i = 0
      Edition.published.includes(:document).where("NOT EXISTS (
          SELECT * FROM edition_relations er
          JOIN documents ON er.document_id=documents.id
          JOIN editions policy_state_check ON documents.id=policy_state_check.document_id
          WHERE
            documents.document_type='Policy'
          AND er.edition_id=editions.id
          AND policy_state_check.state='published'
        )").map do |edition|
        csv << [
          edition.type,
          "https://www.gov.uk" + url_maker.public_document_path(edition),
          "https://whitehall-admin.production.alphagov.co.uk" + url_maker.admin_edition_path(edition),
          edition.lead_organisations.map(&:name).first,
          edition.first_published_at,
          edition.publication_date,
          edition.public_timestamp,
          edition.major_change_published_at,
          edition.updated_at,
          edition.delivered_on
        ]
        i += 1
        if ((i%1000) == 0)
          puts "."
        end
      end
    end
    puts "DONE"
  end
end

EditionsWithoutPolicyReport.new(
  '/data/vhost/whitehall-frontend.production.alphagov.co.uk/shared/editions_without_policy.csv').run!