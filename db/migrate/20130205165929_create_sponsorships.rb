class CreateSponsorships < ActiveRecord::Migration
  def change
    create_table :sponsorships do |t|
      t.references :organisation
      t.references :worldwide_office
      t.timestamps
    end
    add_index :sponsorships, [:organisation_id, :worldwide_office_id], unique: true, name: "unique_sponsorships"
    add_index :sponsorships, :worldwide_office_id
  end
end
