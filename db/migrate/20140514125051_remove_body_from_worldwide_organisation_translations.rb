class RemoveBodyFromWorldwideOrganisationTranslations < ActiveRecord::Migration
  def up
    remove_column :worldwide_organisation_translations, :body
    remove_column :worldwide_organisation_translations, :summary
  end

  def down
    add_column :worldwide_organisation_translations, :summary, :text
    add_column :worldwide_organisation_translations, :body, :text
  end
end
