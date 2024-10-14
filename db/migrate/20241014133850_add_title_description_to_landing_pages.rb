class AddTitleDescriptionToLandingPages < ActiveRecord::Migration[7.1]
  def change
    change_table :landing_pages do |t|
      t.string :title, null: false
      t.text :description, null: false
    end
  end
end
