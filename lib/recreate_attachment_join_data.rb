require 'csv'

class EditionAttachmentOld < ActiveRecord::Base
  self.table_name = "edition_attachments_old"
end

class SupportingPageAttachmentOld < ActiveRecord::Base
  self.table_name = "supporting_page_attachments_old"
end

class ConsultationResponseAttachmentOld < ActiveRecord::Base
  self.table_name = "consultation_response_attachments_old"
end

class CorporateInformationPageAttachmentOld < ActiveRecord::Base
  self.table_name = "corporate_information_page_attachments_old"
end

class AttachmentOld < ActiveRecord::Base
  self.table_name = "attachments_old"

  def path
    Rails.root.join("public/government/uploads/system/uploads/attachment/file/#{id}/#{carrierwave_file}")
  end
end

class RecreateAttachmentJoinData
  def execute(old_join_class, new_join_class, join_field)
    old_join_class.all.each do |old_join_row|
      begin
        old_attachment = AttachmentOld.find(old_join_row.attachment_id)

        File.open(old_attachment.path, 'r:binary') do |file|
          new_attachment_data = AttachmentData.create!(
            file: file,
            content_type: old_attachment.content_type,
            file_size: old_attachment.file_size,
            number_of_pages: old_attachment.number_of_pages
          )

          new_attachment = Attachment.create!(
            title: old_attachment.title,
            accessible: old_attachment.accessible,
            isbn: old_attachment.isbn,
            unique_reference: old_attachment.unique_reference,
            command_paper_number: old_attachment.command_paper_number,
            order_url: old_attachment.order_url,
            price_in_pence: old_attachment.price_in_pence,
            attachment_data_id: new_attachment_data.id
          )

          new_join_class.create!(
            join_field => old_join_row.send(join_field),
            attachment_id: new_attachment.id
          )
          $stdout.puts [old_attachment.path, new_attachment_data.file.path].join(" ")
        end
      rescue Exception => e
        $stderr.puts "ERROR FIXING ATTACHMENT FOR #{old_join_row.id}: #{e.inspect}"
      end
    end
  end
end
