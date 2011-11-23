class AddNumberOfPagesToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :number_of_pages, :integer
  end
end