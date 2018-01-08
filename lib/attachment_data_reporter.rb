require 'csv'

class AttachmentDataReporter

  include ActionView::Helpers::NumberHelper

  attr_reader :data_path, :start_date, :end_date

  def initialize(opts={})
    @data_path  = opts.fetch(:data_path, Rails.root)
    @start_date = Date.parse(opts.fetch(:start_date, 1.month.ago.to_s))
    @end_date   = Date.parse(opts.fetch(:end_date,   1.day.since.to_s))
  end

  def overview
    total = published_editions_with_attachments.map(&:attachments).flatten.size

    grouped_editions = published_editions_with_attachments.group_by { |e| e.organisations.first }

    CSV.open(csv_file_path('overview'), 'wb') do |csv|
      csv << ["Organisation", "Total attachments", "Total accessible", "Content types", "Combined size"]
      grouped_editions.each do |org, editions|
        org_attachments = editions.map(&:attachments).flatten
        org_name = org ? org.name : "No Organisation"
        csv << [org_name, org_attachments.size, accessible_details(org_attachments), content_type_details(org_attachments),
                combined_attachments_file_size(org_attachments)]
      end

      csv << []
      csv << ["Total attachments from #{start_date} to #{end_date}", total, ""]
    end

  end

  def report
    CSV.open(csv_file_path, 'wb') do |csv|
      csv << ["Slug", "Organisations", "Total attachments", "Accessible attachments", "Content types", "Combined size"]
      published_editions_with_attachments.each do |edition|
        csv << [edition.document.slug, edition.organisations.map(&:name).join(","), edition.attachments.size,
                accessible_details(edition.attachments), content_type_details(edition.attachments),
                combined_attachments_file_size(edition.attachments)]
      end
    end
  end

private

  def accessible_count(attachments)
    attachments.inject(0) { |sum, a| sum += a.accessible ? 1 : 0 }
  end

  def accessible_details(attachments)
    count = accessible_count(attachments)
    "#{count} (#{percentage(count, attachments.size)})"
  end

  def content_type_details(attachments)
    attachments.delete_if { |a| a.attachment_data.nil? }
    grouped_attachments = attachments.group_by { |a| a.attachment_data.content_type }
    "".tap do |buf|
      grouped_attachments.each do |mime_type, collection|
        buf << "#{mime_type} : #{collection.size}\n"
      end
    end
  end

  def combined_attachments_file_size(attachments)
    file_sizes = attachments.map do |a|
      a.attachment_data ? a.attachment_data.file_size : 0
    end
    file_sizes.sum
  end

  def published_editions_with_attachments
    @editions ||= Edition.find_by_sql([
      "SELECT e.*
       FROM editions e
       WHERE e.state = 'published'
       AND e.state != 'deleted'
       AND EXISTS(
         SELECT a.id
         FROM attachments a
         WHERE a.attachable_type = 'Edition'
         AND a.attachable_id = e.id
         AND a.attachment_data_id IS NOT NULL
         AND a.created_at BETWEEN ? AND ?
       )
       ORDER BY e.created_at DESC", start_date, end_date
    ])
  end

  def percentage(number, total)
    number_to_percentage((number.to_f / total) * 100)
  end

  def csv_file_path(report_type='report')
    File.join(data_path, "attachments-#{report_type}-#{Time.zone.now.strftime("%y%m%d-%H%M%S")}.csv")
  end
end
