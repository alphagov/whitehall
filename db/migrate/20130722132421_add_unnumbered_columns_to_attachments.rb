class AddUnnumberedColumnsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :unnumbered_command_paper, :boolean
    add_column :attachments, :unnumbered_hoc_paper, :boolean
  end
end
