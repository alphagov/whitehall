# Redirect UKNCP to new location

content_id = "1bc90138-9b23-46ca-8a8f-57c6cc50c9b1"
destination = "/government/organisations/uk-national-contact-point"

PublishingApiRedirectWorker.new.perform(content_id, destination, "en")
