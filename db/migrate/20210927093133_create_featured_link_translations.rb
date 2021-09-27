class CreateFeaturedLinkTranslations < ActiveRecord::Migration[6.1]
  def change
    create_table :featured_link_translations, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.text :url
      t.text :title
      t.string :locale, null: false
      t.integer :featured_link_id, null: false
      t.timestamps

      t.index :locale, name: :index_on_locale
      t.index :featured_link_id, name: :index_on_featured_link
    end
  end
end
