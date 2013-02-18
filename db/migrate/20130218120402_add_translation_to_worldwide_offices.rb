class AddTranslationToWorldwideOffices < ActiveRecord::Migration
  class WorldwideOffice < ActiveRecord::Base
    translates :name, :summary, :description, :services
  end

  def up
    WorldwideOffice.create_translation_table!({
      name: :string, summary: :text, description: :text, services: :text
    }, {
      migrate_data: true
    })
  end

  def down
    WorldwideOffice.drop_translation_table!(migrate_data: true)
  end
end
