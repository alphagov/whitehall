class CreateRoleTranslations < ActiveRecord::Migration
  class Role < ActiveRecord::Base
    translates :name, :responsibilities
  end

  def up
    Role.create_translation_table!({ name: :string, responsibilities: :text }, { migrate_data: true })
  end

  def down
    Role.drop_translation_table!(migrate_data: true)
  end
end
