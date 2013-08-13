class AddFieldsToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :ocpa_regulated, :boolean
    add_column :organisations, :public_meetings, :boolean
    add_column :organisations, :public_minutes, :boolean
    add_column :organisations, :register_of_interests, :boolean
    add_column :organisations, :regulatory_function, :boolean
  end
end
