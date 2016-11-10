doc = Document.find(229878)
PublishingApiDiscardDraftWorker.new.perform(doc.content_id, :en)
