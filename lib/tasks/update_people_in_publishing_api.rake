namespace :publishing_api do
  desc "Updates all people to Publishing API, async"
  task update_all_people_in_publishing_api: :environment do
    Person.find_each do |person|
      Whitehall::PublishingApi.publish_async(person)
    end
  end
end
