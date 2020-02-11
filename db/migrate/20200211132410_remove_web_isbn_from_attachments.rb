class RemoveWebIsbnFromAttachments < ActiveRecord::Migration[5.1]
  def change
    remove_column :attachments, :web_isbn, :string
  end
end
