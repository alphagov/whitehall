class AddPrivyCouncilMembershipToPeople < ActiveRecord::Migration
  def change
    add_column :people, :privy_councillor, :boolean, default: false
    execute %{
      UPDATE people
      SET name = RIGHT(name, LENGTH(name) - 11), privy_councillor = 1
      WHERE name LIKE "The Rt Hon%"
    }
  end
end
