document = Document.find_by_content_id("83f4b752-d52a-4c45-b6d0-368a8e0450e1")

edition = document.editions.published.last
Whitehall::SearchIndex.delete(edition)

document.update!(slug: "imran-gulamhuseinwala-obe-and-joanne-prowse-appointed-as-board-members-of-the-charity-commission")

PublishingApiDocumentRepublishingWorker.new.perform(document.id)

Whitehall::SearchIndex.add(edition)
