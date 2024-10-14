class AddLandingPages < ActiveRecord::Migration[7.1]
  def change
    create_table :landing_pages do |t|
      t.text "base_path", null: false
      t.text "yaml", size: :medium
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
    end

  end
end
