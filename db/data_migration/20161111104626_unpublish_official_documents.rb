doc = Document.find(200300)
# This document was unpublished in Whitehall
# 3 years ago, yet it only has one edition in draft state.
# This is also true in the Publishing API so clean up this
# draft with an unpublishing of type "gone".
PublishingApiGoneWorker.new.perform(doc.content_id, "", "", :en, true)
