class CreateAccessLimitingOrganisation < ActiveRecord::Migration[8.1]
  def change
    create_table :access_limiting_organisations do |t|
      t.timestamps
      t.references :edition, null: false
      t.references :organisation, null: false
    end
  end
end
