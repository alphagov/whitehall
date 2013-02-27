class CreatePersonTranslations < ActiveRecord::Migration
  class Person < ActiveRecord::Base
    translates :biography
  end

  def up
    Person.create_translation_table!({ biography: :text }, { migrate_data: true })
  end

  def down
    Person.drop_translation_table!(migrate_data: true)
  end
end
