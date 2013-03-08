class CreateHtmlVersions < ActiveRecord::Migration
  def change
    create_table :html_versions do |t|
      t.references :edition
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
