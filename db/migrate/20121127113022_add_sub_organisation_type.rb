class AddSubOrganisationType < ActiveRecord::Migration
  def up
    OrganisationType.create!(name: "Sub-organisation", analytics_prefix: "OT")
  end

  def down
    OrganisationType.where(name: "Sub-organisation").delete_all
  end
end
