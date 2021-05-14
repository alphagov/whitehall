namespace :nsca_group_to_org do
  desc "Unpublish and redirect the NSCA PolicyGroup"
  task unpublish_and_redirect: :environment do
    content_id = "eb6556f5-e0c9-4f26-a3d4-66e7f17657d8"
    destination = "/government/organisations/uk-national-screening-committee"

    PublishingApiRedirectWorker.new.perform(content_id, destination, "en")
  end
end
