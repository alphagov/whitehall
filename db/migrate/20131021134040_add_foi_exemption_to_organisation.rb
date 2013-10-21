class AddFoiExemptionToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :foi_exempt, :boolean, null: false, default: false
  end
end
