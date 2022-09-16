document_id = DetailedGuide.find(644_534).document_id

Edition.where(document_id:).destroy_all

Document.find(document_id).destroy!
