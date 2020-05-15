doc = Document.find(229_878)
PublishingApiDiscardDraftWorker.new.perform(doc.content_id, :en)
