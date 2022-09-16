document_id = CorporateInformationPage.find(623_664).document_id

Edition.where(document_id:).destroy_all

Document.find(document_id).destroy!
