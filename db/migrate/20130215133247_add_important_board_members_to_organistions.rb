class AddImportantBoardMembersToOrganistions < ActiveRecord::Migration
  def up
    add_column :organisations, :important_board_members, :integer, default: 1
  end

  def down
    remove_column :organisations, :important_board_members
  end
end
