class DropAccessAndOpeningTimes < ActiveRecord::Migration[7.0]
  def change
    drop_table :access_and_opening_times, id: :integer, charset: "utf8mb3", collation: "utf8_unicode_ci" do |t|
      t.text "body"
      t.string "accessible_type"
      t.integer "accessible_id"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index %w[accessible_id accessible_type], name: "accessible_index"
    end
  end
end
