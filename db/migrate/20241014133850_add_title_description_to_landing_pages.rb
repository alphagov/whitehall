class AddTitleDescriptionToLandingPages < ActiveRecord::Migration[7.1]
  def change
    change_table :landing_pages, bulk: true do |t|
      t.change :base_path, :string
      t.string :title
      t.text :description
      t.index :base_path, unique: true
    end
  end
end
