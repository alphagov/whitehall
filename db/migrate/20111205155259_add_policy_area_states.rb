class AddPolicyAreaStates < ActiveRecord::Migration
  def change
    add_column :policy_areas, :state, :string

    update "UPDATE policy_areas SET state = 'current'"
  end
end