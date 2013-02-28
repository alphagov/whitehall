class RemovePreTranslationWorldwideOrganisationFields < ActiveRecord::Migration
  def change
    remove_column :worldwide_organisations, :name
    remove_column :worldwide_organisations, :summary
    remove_column :worldwide_organisations, :description
    remove_column :worldwide_organisations, :services
  end
end
