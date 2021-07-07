module Reports
  class PublishedAttachmentsReport
    CSV_HEADERS = ["Organisation", "Filename", "Filetype", "Published Date"].freeze

    def report
      path = Rails.root.join("tmp/attachments_#{Time.zone.now.strftime('%d-%m-%Y_%H-%M')}.csv")

      attachments = Attachment.find_by_sql([
        "SELECT a.*
          FROM attachments a
          WHERE a.attachable_type = 'Edition'
          AND a.attachment_data_id IS NOT NULL
          AND EXISTS(
            SELECT e.id
            FROM editions e
            WHERE e.state = 'published'
            AND a.attachable_id = e.id
          )
          AND EXISTS(
            SELECT ad.id
            FROM attachment_data ad
            WHERE ad.id = a.attachment_data_id
          )",
      ])

      CSV.open(path, "wb", headers: CSV_HEADERS, write_headers: true) do |csv|
        attachments.each do |attachment|
          csv << [
            attachment.attachable.organisations.map(&:name).join("; "),
            attachment.url,
            attachment.content_type,
            attachment.updated_at,
          ]
          print(".")
        end
      end

      puts "Finished! Report available at #{path}"
    end
  end
end
