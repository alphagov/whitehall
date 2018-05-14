slug = "jhub-defence"
redirect_path = "/government/organisations/jhub-defence-innovation"

group = PolicyGroup.find_by(slug: slug)
exit unless group

content_id = group.content_id

group.delete

PublishingApiRedirectWorker.new.perform(content_id, redirect_path, "en")
