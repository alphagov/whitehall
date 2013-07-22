class AddHocPaperColumnsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :hoc_paper_number, :string
    add_column :attachments, :parliamentary_session, :string
  end
end
