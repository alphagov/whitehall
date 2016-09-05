document_id = CorporateInformationPage.find(623664).document_id

Edition.where(document_id: document_id).destroy_all

Document.find(document_id).destroy
