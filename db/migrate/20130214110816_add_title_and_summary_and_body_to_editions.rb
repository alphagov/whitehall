class AddTitleAndSummaryAndBodyToEditions < ActiveRecord::Migration
  class Edition < ActiveRecord::Base; end

  def up
    if title_and_summary_and_body_columns_exist_on_editions?
      puts "*** Title, summary and body columns already exist on editions - skipping migration."
      return
    end

    change_table :editions do |t|
      t.string :title
      t.text :summary
      t.text :body, limit: 16.megabytes - 1
    end

    update %{
      UPDATE editions, edition_translations
        SET editions.title = edition_translations.title,
            editions.summary = edition_translations.summary,
            editions.body = edition_translations.body,
            editions.updated_at = GREATEST(editions.updated_at, edition_translations.updated_at)
        WHERE editions.id = edition_translations.edition_id
          AND locale = 'en'
    }
  end

  def down
    # Intentionally blank.
    #
    # This migration was added to ensure that our development machines, CI and Preview are kept in sync with Production,
    # after editing the 20130211090000_create_edition_translations.rb migration.
  end

  def title_and_summary_and_body_columns_exist_on_editions?
    (%w(title summary body) - Edition.column_names).empty?
  end
end
