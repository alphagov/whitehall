# Quite a few published DetailedGuides do not have items in the content store
# (~1700 out of ~3800 at time of writing). This task republishes all
# DetailedGuides to correctly create the corresponding content items.

DetailedGuide.published.joins(:document).find_each do |dg|
  Whitehall::PublishingApi.republish_document_async(dg.document)
end
