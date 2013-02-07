class RemoveCountryFromContactsWithBlankAddress < ActiveRecord::Migration
  class Contact < ActiveRecord::Base
  end

  def up
    Contact.where(street_address: "").each do |contact|
      contact.country_id = nil
      contact.save
    end
  end

  def down
  end
end
