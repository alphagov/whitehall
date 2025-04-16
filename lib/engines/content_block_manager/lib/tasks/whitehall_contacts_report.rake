namespace :content_block_manager do
  desc "Create csv report of Contact data"
  task :whitehall_contacts_report => :environment do
    
    file = "#{Rails.root}/tmp/2025-04-09-contacts.csv"

    # get all the Organisations with their contacts
    orgs = Organisation.joins(:contacts => :contact_numbers).distinct

    worldwide_offices = WorldwideOffice.joins(:contact => :contact_numbers).distinct.joins(:edition)

    # for each contact print to a row
    CSV.open(file, 'w') do |csv|
      orgs.each do |org|
        org.contacts.each do |contact|
          dependencies = EditionDependency.where(dependable_id: contact.id)
          contact_numbers_count = 	contact.contact_numbers.count
          contact_numbers = contact.contact_numbers.map(&:number)

          csv << [
            org.name,
            org.govuk_status,
            contact.id,
            contact.title,
            dependencies.count,
            contact.contactable_type,
            contact.street_address,
            contact.locality,
            contact.region,
            contact.postal_code,
            contact.country_id,
            contact.email,
            contact.contact_type_id,
            contact.contact_form_url,
            contact_numbers_count,
            contact_numbers,
          ]
        end
      end

      worldwide_offices.each do |org|
        contact = org.contact

        contact_numbers_count = 	contact.contact_numbers.count
        contact_numbers = contact.contact_numbers.map(&:number)
        state = org.edition.state
        dependencies = EditionDependency.where(dependable_id: org.edition.id)

        csv << [
          org.title,
          state,
          contact.id,
          contact.title,
          dependencies.count,
          contact.contactable_type,
          contact.street_address,
          contact.locality,
          contact.region,
          contact.postal_code,
          contact.country_id,
          contact.email,
          contact.contact_type_id,
          contact.contact_form_url,
          contact_numbers_count,
          contact_numbers,
        ]
      end
    end
  end
end