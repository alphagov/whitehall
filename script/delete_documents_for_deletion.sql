create temporary table latest_editions
select document_identity_id, max(id) as latest_document_id
from documents
group by document_identity_id;

create temporary table document_identities_to_delete
select documents.document_identity_id
from latest_editions
inner join documents 
on latest_editions.latest_document_id = documents.id 
where documents.title like "%delete%"
and documents.state <> 'deleted';

-- *** Document Relations
create temporary table document_relations_to_delete
select id from document_relations
where document_identity_id in (select document_identity_id from document_identities_to_delete);

insert into document_relations_to_delete
select id from document_relations
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(distinct(id)) from document_relations_to_delete;

-- *** Consultation responses
select count(*) from documents
where consultation_document_identity_id in (select document_identity_id from document_identities_to_delete)
and documents.type = 'ConsultationResponse';

-- *** Documents
select count(*) from documents 
where document_identity_id in (select document_identity_id from document_identities_to_delete);

select count(*) from document_attachments
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from document_authors 
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from document_countries 
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from document_ministerial_roles
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from document_organisations
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from fact_check_requests
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from editorial_remarks
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from images
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from nation_inapplicabilities
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

select count(*) from supporting_pages
where document_id in (
  select documents.id from documents
  inner join document_identities_to_delete
  on documents.document_identity_id = document_identities_to_delete.document_identity_id);

/*
grep "INSERT INTO \`document_attachments\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`document_authors\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`document_countries\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`document_identities\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`document_ministerial_roles\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`document_organisations\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`document_relations\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`documents\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`fact_check_requests\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`editorial_remarks\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`images\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`nation_inapplicabilities\`" whitehall.sql.diff | wc -l
grep "INSERT INTO \`supporting_pages\`" whitehall.sql.diff | wc -l
*/