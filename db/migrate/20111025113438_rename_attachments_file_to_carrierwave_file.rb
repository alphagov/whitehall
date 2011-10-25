class RenameAttachmentsFileToCarrierwaveFile < ActiveRecord::Migration
  def change
    rename_column :attachments, :file, :carrierwave_file
  end
end
