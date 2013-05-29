class DropLegacyTranslatedColumns < ActiveRecord::Migration
  def change
    remove_columns :corporate_information_pages, :summary, :body
    remove_columns :organisations, :name, :logo_formatted_name, :acronym, :description, :about_us
    remove_columns :roles, :name, :responsibilities
    remove_columns :people, :biography
  end
end
