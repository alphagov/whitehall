class CreateSitewideSettings < ActiveRecord::Migration
  def change
    create_table :sitewide_settings do |t|
      t.string :key, unique: true
      t.text :description
      t.boolean :on
      t.text :govspeak

      t.timestamps
    end
  end
end
