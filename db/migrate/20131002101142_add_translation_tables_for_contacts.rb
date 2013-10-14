class AddTranslationTablesForContacts < ActiveRecord::Migration
  def up
    Contact.create_translation_table!({ title: :string,
                                        comments: :text,
                                        recipient: :string,
                                        street_address: :text,
                                        locality: :string,
                                        region: :string,
                                        email: :string,
                                        contact_form_url: :string },
                                      { migrate_data: true })
  end

  def down
    Contact.drop_translation_table!(migrate_data: true)
  end
end
