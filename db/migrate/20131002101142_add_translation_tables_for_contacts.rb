class AddTranslationTablesForContacts < ActiveRecord::Migration
  class Contact < ActiveRecord::Base
    # without this .create_translation_table! doesn't exist
    translates :title, :comments, :recipient, :street_address, :locality,
               :region, :email, :contact_form_url
  end

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
