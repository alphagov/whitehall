class AddWorldwideOrganisationPageTranslationsTable < ActiveRecord::Migration[7.1]
  def up
    WorldwideOrganisationPage.create_translation_table! title: :string, summary: :text, body: :text
  end

  def down
    WorldwideOrganisationPage.drop_translation_table!
  end
end
