class AddSubmittedFlagToPolicies < ActiveRecord::Migration
  def change
    add_column :policies, :submitted, :boolean, default: false
  end
end