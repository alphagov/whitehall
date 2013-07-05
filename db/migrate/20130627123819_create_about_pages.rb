class CreateAboutPages < ActiveRecord::Migration
  def change
    create_table :about_pages do |t|
      t.integer :topical_event_id

      t.string :name
      t.text :summary
      t.text :body
      t.string :read_more_link_text

      t.timestamps
    end
  end
end
