# Redirect the current finder sitting at /government/world/organisations to the new location

content_id = "b8faa6b3-e9b0-41fb-a415-92af505277ca"
destination = "/world/organisations"

PublishingApiRedirectWorker.new.perform(content_id, destination, I18n.default_locale.to_s)
