content_id = "73c5fd84-e356-4d8e-98cc-bbe82d73a7c7"
redirect_path = "/check-tenant-right-to-rent-documents"
PublishingApiRedirectWorker.new.perform(content_id, redirect_path, "en", false)
