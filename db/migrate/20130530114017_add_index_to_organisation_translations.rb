class AddIndexToOrganisationTranslations < ActiveRecord::Migration
  def change
    change_column :organisation_translations, :name, :string
    add_index :organisation_translations, :name
  end
end
