class AddTranslationTableForContactNumbers < ActiveRecord::Migration
  def up
    ContactNumber.create_translation_table!({ label: :string,
                                              number: :string },
                                            { migrate_data: true })
  end

  def down
    ContactNumber.drop_translation_table!(migrate_data: true)
  end
end
