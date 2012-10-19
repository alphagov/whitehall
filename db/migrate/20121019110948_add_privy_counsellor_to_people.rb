class AddPrivyCounsellorToPeople < ActiveRecord::Migration
  def change
    add_column :people, :privy_counsellor, :boolean, default: false
    remove_column :people, :privy_councillor
  end
end
