class AddConsultationResponses < ActiveRecord::Migration
  def up
    create_table :responses, force: true do |t|
      t.integer :edition_id
      t.text :summary
      t.timestamps
    end
  end

  def down
    drop_table :responses
  end
end