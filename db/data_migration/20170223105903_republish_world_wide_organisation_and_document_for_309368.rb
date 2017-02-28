# Sync check is failing for WLNA with a document id 309368
# for some reason the world wide organisation is out of sync so....
# republish the associated world wide organisation and then
# republish the document.

wwo = WorldwideOrganisation.find(373)
wwo.save if wwo

PublishingApiDocumentRepublishingWorker.new.perform(309368)
