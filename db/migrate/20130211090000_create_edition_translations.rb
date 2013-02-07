class CreateEditionTranslations < ActiveRecord::Migration
  class Edition < ActiveRecord::Base
    translates :title, :summary, :body
  end

  def up
    Edition.create_translation_table!({
      title: :string,
      summary: :text,
      body: { type: :text, limit: 16.megabytes - 1 }
    })

    insert %{
      INSERT INTO edition_translations (edition_id, locale, title, summary, body, created_at, updated_at)
        SELECT id, 'en', title, summary, body, NOW(), updated_at FROM editions
    }

    remove_column :editions, :title
    remove_column :editions, :summary
    remove_column :editions, :body
  end

  def down
    add_column :editions, :title, :string
    add_column :editions, :summary, :text
    add_column :editions, :body, :text, limit: 16.megabytes - 1

    update %{
      UPDATE editions, edition_translations
        SET editions.title = edition_translations.title,
            editions.summary = edition_translations.summary,
            editions.body = edition_translations.body,
            editions.updated_at = GREATEST(editions.updated_at, edition_translations.updated_at)
        WHERE editions.id = edition_translations.edition_id
          AND locale = 'en'
    }

    Edition.drop_translation_table!
  end
end
