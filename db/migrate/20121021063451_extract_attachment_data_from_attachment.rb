class ExtractAttachmentDataFromAttachment < ActiveRecord::Migration
  class EditionAttachment < ActiveRecord::Base
    belongs_to :attachment
  end

  class ConsultationResponseAttachment < ActiveRecord::Base
    belongs_to :attachment
  end

  class CorporateInformationPageAttachment < ActiveRecord::Base
    belongs_to :attachment
  end

  class SupportingPageAttachment < ActiveRecord::Base
    belongs_to :attachment
  end

  class AttachmentData < ActiveRecord::Base
  end

  class Attachment < ActiveRecord::Base
    belongs_to :attachment_data
  end

  def move_files(old_id, new_id)
    old_dir = "#{Rails.root}/public/system/uploads/attachment/file/#{old_id}"
    new_dir = "#{Rails.root}/public/system/uploads/attachment_data/file/#{new_id}"
    cmd = "[ -e #{old_dir} ] && mkdir -p #{new_dir} && mv -f #{old_dir}/* #{new_dir}/"
    system cmd
  end

  def extract_attachment_data_from(klass)
    attachment_to_data_map = {}
    puts "Extracting attachment data from #{klass}"
    system "mkdir -p #{Rails.root}/public/system/uploads/attachment_data/"
    klass.all.each do |row|
      old_attachment = row.attachment
      if (old_attachment)
        row.create_attachment!(old_attachment.attributes)
        if (attachment_to_data_map[old_attachment.id])
          row.attachment.attachment_data = attachment_to_data_map[old_attachment.id]
        else
          attachment_to_data_map[old_attachment.id] =
            row.attachment.create_attachment_data!(
              carrierwave_file: old_attachment.carrierwave_file,
              content_type: old_attachment.content_type,
              file_size: old_attachment.file_size,
              number_of_pages: old_attachment.number_of_pages
            )
          move_files(old_attachment.id, row.attachment.attachment_data.id)
        end
        row.attachment.save!
        row.save!

      else
        row.update_attributes(attachment_id: nil)
      end
    end
    puts "Destroying old attachments"
    klass.delete_all(id: attachment_to_data_map.keys)
  end

  def up
    create_table :attachment_data, force: true do |t|
      t.string :carrierwave_file
      t.string :content_type
      t.integer :file_size
      t.integer :number_of_pages

      t.timestamps
    end

    add_column :attachments, :attachment_data_id, :integer

    extract_attachment_data_from(EditionAttachment)
    extract_attachment_data_from(SupportingPageAttachment)
    extract_attachment_data_from(CorporateInformationPageAttachment)
    extract_attachment_data_from(ConsultationResponseAttachment)

    remove_column :attachments, :carrierwave_file
    remove_column :attachments, :content_type
    remove_column :attachments, :file_size
    remove_column :attachments, :number_of_pages
  end

  def down
    add_column :attachments, :carrierwave_file, :string
    add_column :attachments, :content_type, :string
    add_column :attachments, :file_size, :string
    add_column :attachments, :number_of_pages, :string

    remove_column :attachments, :attachment_data

    drop_table :attachment_data
  end
end
