class CreateAboutPages < ActiveRecord::Migration
  def change
    create_table :about_pages do |t|
      t.integer :subject_id
      t.string :subject_type

      t.string :name
      t.text :summary
      t.text :body
      t.string :read_more_link_text

      t.timestamps
    end
  end
end
