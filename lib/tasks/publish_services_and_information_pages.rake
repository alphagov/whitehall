namespace :services_information do
  desc 'Publish all services and information pages to the publishing API'
  task publish: :environment do
    organisations = Organisation.new.organisations_with_services_and_information_link
    Organisation.where(slug: organisations).each do |organisation|
      puts "Publishing services and information page for #{organisation.name}"

      Whitehall::PublishingApi.publish_services_and_information_async(organisation.id)
    end
  end
end
