# The organisation, Academy for Social Justice, is available at
# https://www.gov.uk/government/organisations/academy-for-social-justice
#
# It replaces the Academy for Social Justice Commissioning, available at
# https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning

# And that, in turn, replaces the Academy for Justice Commissioning, available at
# https://www.gov.uk/government/organisations/academy-for-justice-commissioning
#
# The two older organisations (and their CorporateInformationPages) appear to have
# been deleted sometime around the request for the org name change in
# https://govuk.zendesk.com/agent/tickets/3587898 in 2019.
#
# That should not have happened - the orgs and pages should have remained in
# Whitehall, but the org should have been 'Closed'.
#
# Taking https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about
# as an example, if we look up the document in Whitehall, the doc
# exists, but there are no editions obviously associated with it.
#
# ```
# Document.find_by(content_id: "a1234754-c53e-4aa9-a721-b7e333128a85")
# => 
# #<Document:0x0000ffff95ec8700
#  id: 348460,
#  created_at: "2017-01-10 18:05:40.000000000 +0000",
#  updated_at: "2024-08-28 14:17:30.000000000 +0100",
#  slug: "348460",
#  document_type: "CorporateInformationPage",
#  content_id: "a1234754-c53e-4aa9-a721-b7e333128a85",
#  latest_edition_id: nil,
#  live_edition_id: nil>
# ```
# 
# ...that is until we use the `unscoped` scope to bring 'deleted' items back into the fold:
# ```
# Edition.unscoped.where(document_id: 348460)
# => 
# [#<CorporateInformationPage:0x0000ffff912e2818
#   id: 757630,
#   created_at: "2017-08-16 11:48:29.000000000 +0100",
#   updated_at: "2017-08-16 13:12:24.000000000 +0100",
#   lock_version: 9,
#   document_id: 348460,
#   state: "deleted",
#   type: "CorporateInformationPage",
#   ...,
#   title: "About us",
#   summary: "The Academy for Social Justice Commissioning ident...",
#   body: "We now have over 3500 members from the public, pri...",
#   flexible_page_content: nil>]
# ```
#
# We aren't so lucky with the organisations themselves:
# ````
# Organisation.unscoped.find_by(content_id: "ce357bdb-6396-426a-9f1f-8cbfb444cffd")
# => nil
# ````
#
# We therefore need to manually re-create the organisations, and
# un-delete their CorporateInformationPages.

# FIXING OLD ORGANISATION
# -------------------
# https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning
organisation = Organisation.create!(
  content_id: "ce357bdb-6396-426a-9f1f-8cbfb444cffd",
  slug: "academy-for-social-justice-commissioning",
  name: "Academy for Social Justice Commissioning",
  organisation_type_key: :other,
  logo_formatted_name: "Acadamy for Social Justice Commissioning",
  govuk_status: "closed",
  govuk_closed_status: "changed_name",
  homepage_type: "news",
  political: false,
  analytics_identifier: "OT1208",
  superseding_organisations: [Organisation.find_by(slug: "academy-for-social-justice")],
)

# Fixing CorporateInformationPage https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about
doc = Document.find_by(content_id: "a1234754-c53e-4aa9-a721-b7e333128a85")
deleted_page = Edition.unscoped.find_by(document_id: doc.id)
deleted_page.update(state: "published", organisation: organisation)

# Fixing CorporateInformationPage https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about/our-governance
doc = Document.find_by(content_id: "855cc082-22ca-450a-b30d-937ca1caa24d")
deleted_page = Edition.unscoped.find_by(document_id: doc.id)
# nil. Argh. TODO: something.

# Fixing CorporateInformationPage https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about/membership
doc = Document.find_by(content_id: "7b93c1e5-f839-4330-88a7-060ba58aa642")
deleted_page = Edition.unscoped.find_by(document_id: doc.id)
deleted_page.update(state: "published", organisation: organisation)
# for some reason, that only sets the relationship one way
# (deleted_page.organisation links to org, but organisation.corporate_information_pages doesn't surface this
# extra page)
# so we have to hack it in
organisation.corporate_information_pages << deleted_page

# Fixing CorporateInformationPage https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about/about-our-services
doc = Document.find_by(content_id: "e52f65ae-872b-4d3c-a697-79f6ff74a9b1")
deleted_page = Edition.unscoped.find_by(document_id: doc.id)
organisation.corporate_information_pages << deleted_page

# FIXING OLDER ORGANISATION
# -------------------
# https://www.gov.uk/government/organisations/academy-for-justice-commissioning
organisation = Organisation.create!(
  content_id: "4dfe21ee-acfa-4fc1-9513-cc764e814205",
  slug: "academy-for-justice-commissioning",
  name: "Academy for Justice Commissioning",
  organisation_type_key: :other,
  logo_formatted_name: "Acadamy for Justice Commissioning",
  govuk_status: "closed",
  govuk_closed_status: "changed_name",
  homepage_type: "news",
  political: false,
  analytics_identifier: "OT1025",
  superseding_organisations: [Organisation.find_by(slug: "academy-for-social-justice-commissioning")],
)

# Fixing CorporateInformationPage https://www.gov.uk/government/organisations/academy-for-justice-commissioning/about
doc = Document.find_by(content_id: "5f5b90be-7631-11e4-a3cb-005056011aef")
deleted_page = Edition.unscoped.find_by(document_id: doc.id)
deleted_page.update(state: "published", organisation: organisation)
organisation.corporate_information_pages << deleted_page
# TODO: for some reason the content is uneditable. "There is a mistake in the URL"
# https://whitehall-admin.staging.publishing.service.gov.uk/government/admin/editions/1702029/force_publish?lock_version=21

# Fixing CorporateInformationPage https://www.gov.uk/government/organisations/academy-for-justice-commissioning/about/membership
doc = Document.find_by(content_id: "5fe5063c-7631-11e4-a3cb-005056011aef")
deleted_page = Edition.unscoped.find_by(document_id: doc.id)
deleted_page.update(state: "published", organisation: organisation)
organisation.corporate_information_pages << deleted_page
