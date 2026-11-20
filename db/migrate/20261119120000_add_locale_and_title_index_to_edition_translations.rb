class AddLocaleAndTitleIndexToEditionTranslations < ActiveRecord::Migration[8.1]
  def change
    add_index :edition_translations,
              %i[locale title edition_id],
              name: "index_edition_translations_on_locale_and_title_and_edition_id"
  end
end
