# This script takes broken existing URLs of assets and looks for
# equivalent files that actually do exist, for the purposes of fixing
# broken redirects.

require 'csv'
require 'ostruct'

def url_maker
  @url_maker ||= Whitehall::UrlMaker.new(host: "www.gov.uk")
end

def find_edition_by_attachment(url)
  parts = url.split('/')
  edition_id = parts[-2]
  file_name = parts[-1]
  edition = Edition.unscoped.find(EditionAttachment.where(attachment_id: Attachment.where(attachment_data_id: edition_id).first.id).first.edition_id)
  if edition.state != 'published'
    AttachmentData.find(:all, conditions: ['carrierwave_file = ? AND NOT id = ?', file_name, edition_id]).each do |attachment|
      edition = Edition.unscoped.find(EditionAttachment.where(attachment_id: Attachment.where(attachment_data_id: attachment.id).first.id).first.edition_id)
      if edition.state == 'published'
        return url_maker.url_for(Attachment.where(attachment_data_id: attachment.id).first.url)
      end
    end
  end
  nil
end

CSV.open('/var/govuk/fixed-files.csv', 'wb') do |csv_out|
  csv_out << ['Old Url', 'New Url', 'Status']
  CSV.open('/var/govuk/dead-files.csv').each do |row|
    if attachment_url = find_edition_by_attachment(row[1])
      csv_out << [row[0], 'https://www.gov.uk/government/uploads' + attachment_url, '301']
    else
      p 'not found'
      csv_out << [row[0], nil, '410']
    end
  end
end
