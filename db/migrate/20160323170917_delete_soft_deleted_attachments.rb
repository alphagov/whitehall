class DeleteSoftDeletedAttachments < ActiveRecord::Migration
  class Attachment < ActiveRecord::Base; end

  def change
    Attachment.destroy_all(deleted: true)
  end
end
