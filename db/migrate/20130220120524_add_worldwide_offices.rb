class AddWorldwideOffices < ActiveRecord::Migration
  class Contact < ActiveRecord::Base
  end
  class WorldwideOffice < ActiveRecord::Base
  end
  class WorldwideOrganisation < ActiveRecord::Base
  end

  def up
    create_table :worldwide_offices, force: true do |t|
      t.references :worldwide_organisation
      t.timestamps
    end
    add_index :worldwide_offices, :worldwide_organisation_id

    rename_column :worldwide_organisations, :main_contact_id, :main_office_id

    WorldwideOffice.reset_column_information
    WorldwideOrganisation.reset_column_information
    Contact.reset_column_information

    Contact.where(contactable_type: 'WorldwideOrganisation').each do |c|
      woffice = WorldwideOffice.create!(worldwide_organisation_id: c.contactable_id)
      c.update_attributes!(contactable_id: woffice.id, contactable_type: 'WorldwideOffice')
    end

    WorldwideOrganisation.all.each do |worg|
      if worg.main_office_id
        contact = Contact.find(worg.main_office_id)
        worg.update_column(main_office_id: contact.contactable_id)
      end
    end
  end

  def down
    rename_column :worldwide_organisations, :main_office_id, :main_contact_id

    WorldwideOrganisation.all.each do |worg|
      if worg.main_contact_id
        woff = WorldwideOffice.find(worg.main_contact_id)
        worg.update_column(main_contact_id: woff.contact.id)
      end
    end

    WorldwideOrganisation.reset_column_information
    WorldwideOffice.reset_column_information
    Contact.reset_column_information
    Contact.where(contactable_type: 'WorldwideOffice').each do |c|
      woffice = WorldwideOffice.find(c.contactable_id)
      c.update_attributes!(contactable_id: woffice.worldwide_organisation_id, contactable_type: 'WorldwideOrganisation')
    end

    drop_table :worldwide_offices
  end
end
