class CreateHtmlVersions < ActiveRecord::Migration
  def change
    create_table :html_versions do |t|
      t.references :edition
      t.string :title
      t.text :body
      t.string :slug

      t.timestamps
    end

    add_index :html_versions, :slug
  end
end
