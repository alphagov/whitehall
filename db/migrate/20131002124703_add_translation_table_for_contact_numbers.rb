class AddTranslationTableForContactNumbers < ActiveRecord::Migration
  class ContactNumber < ActiveRecord::Base
    # without this .create_translation_table! doesn't exist
    translates :label, :number
  end

  def up
    ContactNumber.create_translation_table!({ label: :string,
                                              number: :string },
                                            { migrate_data: true })
  end

  def down
    ContactNumber.drop_translation_table!(migrate_data: true)
  end
end
