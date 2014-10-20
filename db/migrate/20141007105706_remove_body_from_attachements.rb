class RemoveBodyFromAttachements < ActiveRecord::Migration
  def change
    remove_columns :attachments, :body, :manually_numbered_headings
  end
end
