publication  = Publication.find(373322)
unpublishing = publication.unpublishing
redirect_url = "#{Whitehall.public_root}/government/publications/review-of-radiation-dose-issues-from-the-use-of-ct-in-the-uk"

puts "Updating the unpublishing reason and setting up a redirect to #{redirect_url}"
unpublishing.unpublishing_reason_id = UnpublishingReason::Consolidated.id
unpublishing.redirect = true
unpublishing.alternative_url = redirect_url
unpublishing.save!

puts "Resetting the publication back to draft so that it's no longer \"archived\" and is instead \"unpublished\""
publication.update_attribute(:state, "draft")
