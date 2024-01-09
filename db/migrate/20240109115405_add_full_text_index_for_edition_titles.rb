class AddFullTextIndexForEditionTitles < ActiveRecord::Migration[7.1]
  def change
    add_index :edition_translations, :title, type: :fulltext, if_not_exists: true
  end
end
