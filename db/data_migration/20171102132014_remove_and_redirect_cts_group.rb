slug = "common-technology-services-cts"
redirect_path = "/government/publications/technology-code-of-practice/technology-code-of-practice"

group = PolicyGroup.find_by(slug: slug)
exit unless group

content_id = group.content_id

group.delete
PublishingApiRedirectWorker.new.perform(content_id, redirect_path, "en")

puts "#{slug} -> #{redirect_path}"
