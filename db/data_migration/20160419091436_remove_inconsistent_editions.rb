# Remove editions that do not have an associated documents.
# This is not enforced in the database via a foreign key.
# Edition.where("not exists (select 1 from documents where documents.id = document_id)")

CorporateInformationPage.delete(336_520)
