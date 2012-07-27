class AddCommandPaperNumberToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :command_paper_number, :string
  end
end