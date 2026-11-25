class IndexEditionTranslationsByTitle < ActiveRecord::Migration[8.1]
  def change
    change_table :edition_translations, bulk: true do |t|
      t.index %i[locale title edition_id],
              name: "index_edition_translations_on_locale_and_title_and_edition_id"

      t.remove_index :locale,
                     name: "index_edition_translations_on_locale"
    end
  end
end
