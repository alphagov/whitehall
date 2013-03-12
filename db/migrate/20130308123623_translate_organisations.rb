class TranslateOrganisations < ActiveRecord::Migration
  class Organisation < ActiveRecord::Base
    translates :name, :logo_formatted_name, :acronym, :description, :about_us
  end

  def up
    Organisation.create_translation_table!(
      { name: :text,
        logo_formatted_name: :text,
        acronym: :string,
        description: :text,
        about_us: :text },
      { migrate_data: true })
  end

  def down
    Organisation.drop_translation_table!(migrate_data: true)
  end
end
