class RemoveImportantBoardMembersFromOrganisations < ActiveRecord::Migration[7.1]
  def change
    remove_column :organisations, :important_board_members, :integer
  end
end
