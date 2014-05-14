class RemoveAboutUsFromOrganisationTranslations < ActiveRecord::Migration
  def up
    remove_column :organisation_translations, :description
    remove_column :organisation_translations, :about_us
  end

  def down
    add_column :organisation_translations, :about_us, :text
    add_column :organisation_translations, :description, :text
  end
end
