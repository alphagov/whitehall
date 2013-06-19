class AddTitleToAttachments < ActiveRecord::Migration
  class AttachmentTable < ActiveRecord::Base
    self.table_name = "attachments"
  end
  def change
    add_column :attachments, :title, :string
    AttachmentTable.all.each do |attachment|
      extension = File.extname(attachment.carrierwave_file)
      basename = File.basename(attachment.carrierwave_file, extension)
      generated_title = basename.gsub(/_+/, " ").gsub(/[^\w]+/, " ").humanize
      attachment.update_attributes(title: generated_title)
    end
  end
end