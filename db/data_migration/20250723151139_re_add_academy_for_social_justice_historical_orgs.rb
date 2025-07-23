# The organisation, Academy for Social Justice, is available at
# https://www.gov.uk/government/organisations/academy-for-social-justice
# It replaces the Academy for Social Justice Commissioning, available at
# https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning
# And that, in turn, replaces the Academy for Justice Commissioning, available at
# https://www.gov.uk/government/organisations/academy-for-justice-commissioning
#
# The two older organisations (and their CorporateInformationPages) appear to have
# been deleted sometime around the request for the org name change in
# https://govuk.zendesk.com/agent/tickets/3587898 in 2019.
# That should not have happened - the orgs and pages should have remained in
# Whitehall, but the org should have been 'Closed'.
#
# The orgs themselves are gone permanently:
# ````
# Organisation.unscoped.find_by(content_id: "ce357bdb-6396-426a-9f1f-8cbfb444cffd")
# => nil
# ````
# ...so we'll have to recreate them here.
#
# The corporate information pages seem to be largely intact, provided we use
# the `unscoped` scope to include 'deleted' editions in our search.
# We therefore want to bring these back as 'published' editions so that they
# continue to be editable (using the `reinstate_corporate_information_page`
# helper method defined in this data migration).
#
# Example: https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about
# ```
# Document.find_by(content_id: "a1234754-c53e-4aa9-a721-b7e333128a85")
# =>
# #<Document:0x0000ffff95ec8700
#  id: 348460,
#  ...
# >
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
# The full list of corporate information pages was derived by:
# ContentItem.where(rendering_app: "government-frontend").find_each do |page|
#   puts page.base_path if page.base_path.include?("government/organisations")
# end
# =>
# /government/organisations/academy-for-social-justice-commissioning/about
# /government/organisations/academy-for-social-justice-commissioning/about/membership
# /government/organisations/academy-for-social-justice-commissioning/about/about-our-services
# /government/organisations/academy-for-social-justice-commissioning/about/our-governance
# /government/organisations/academy-for-justice-commissioning/about
# /government/organisations/academy-for-justice-commissioning/about/membership
#

def reinstate_corporate_information_page(content_id, organisation)
  doc = Document.find_by(content_id: content_id)
  deleted_page = Edition.unscoped.find_by(document_id: doc.id)
  deleted_page.update!(state: "published", organisation: organisation)
  organisation.corporate_information_pages << deleted_page
end

# Recreate 'Academy for Social Justice Commissioning' org, using details derived from live content item for
# https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning
academy_for_social_justice_commissioning = Organisation.create!(
  content_id: "ce357bdb-6396-426a-9f1f-8cbfb444cffd",
  slug: "academy-for-social-justice-commissioning",
  name: "Academy for Social Justice Commissioning",
  organisation_type_key: :other,
  logo_formatted_name: "Academy for Social Justice Commissioning",
  govuk_status: "closed",
  govuk_closed_status: "changed_name",
  homepage_type: "news",
  political: false,
  analytics_identifier: "OT1208",
  superseding_organisations: [Organisation.find_by(slug: "academy-for-social-justice")],
)

[
  "a1234754-c53e-4aa9-a721-b7e333128a85", # https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about
  "7b93c1e5-f839-4330-88a7-060ba58aa642", # https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about/membership
  "e52f65ae-872b-4d3c-a697-79f6ff74a9b1", # https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about/about-our-services
].each do |content_id|
  reinstate_corporate_information_page(content_id, academy_for_social_justice_commissioning)
end

# The "About" page was not editable because of the following line of GovSpeak:
# `[academy strategy group](/government/admin/organisations/academy-for-justice-commissioning/corporate_information_pages/372537)`
# On creation of a new Edition, Whitehall would crash in the `AdminLinkLookup.corporate_info_page` because of
# the `AdminLinkReplacer.replace!` method further down in the stack:
# `Couldn't find CorporateInformationPage with 'id'=372537 [WHERE `editions`.`type` = ?]`.
# Whitehall has some complex logic to keep 'internal' links up to date on each edit, but in this
# case Edition 372537 no longer exists. The fix is either to update it to the ID of the reinstated
# edition, or, more prudently, remove the link altogether, since the currently live version doesn't
# even render as a link.
about_us_doc = Document.find_by(content_id: "a1234754-c53e-4aa9-a721-b7e333128a85")
about_us_edition = Edition.find_by(document_id: about_us_doc.id)
about_us_edition.body = about_us_edition.body.sub(/\[academy strategy group\]\([^)]+\)/, "academy strategy group")
about_us_edition.save!(validate: false)

# The "our governance" page (https://www.gov.uk/government/organisations/academy-for-social-justice-commissioning/about/our-governance)
# seems to have been permanently erased from Whitehall.
# Even tried a wildcard search which returned no results.
# `GovspeakContent.where("body LIKE ?", "%strategy group provide the business oversight and operational management functions of the Academy for Social Justice Commissioning%").find_each { |content| puts content.id }`
# So we'll recreate it manually below.
our_governance_page = academy_for_social_justice_commissioning.build_corporate_information_page(
  corporate_information_page_type_id: 5,
  creator: User.find_by(name: "Scheduled Publishing Robot", uid: nil), # our de facto 'system' user
  state: "published",
  minor_change: true,
  # `major_change_published_at` based on latest change history timestamp
  # in the live content item:
  # "change_history": [
  #   {
  #     "note": "We have added a Privacy Policy",
  #     "public_timestamp": "2018-06-04T13:53:28.000+01:00"
  #   },
  #   {
  #     "note": "Added Personal Information Charter details with reference to the Data Protection Act",
  #     "public_timestamp": "2018-05-24T09:54:07.000+01:00"
  #   },
  #   {
  #     "note": "First published.",
  #     "public_timestamp": "2017-01-10T18:15:24.000+00:00"
  #   }
  # ],
  major_change_published_at: Time.zone.parse("2018-06-04T13:53:28.000+01:00"),
  summary: "The academy strategy group provides business oversight and the operational management functions of the Academy for Social Justice Commissioning.",
  body: <<~GOVSPEAK,
    ## Terms of reference

    The strategy group provide the business oversight and operational management functions of the Academy for Social Justice Commissioning.

    1. To plan, implement and manage objectives as identified in the annual business plan.
    2. To specify, oversee and co-ordinate the outputs of the core work groups - strategy and communications, membership service and learning and development - and provide appropriate authority where required.
    3. To ensure appropriate financial management and control.
    4. To ensure appropriate engagement with stakeholders within the social justice sector and maintain links with other relevant government departments, private and 3rd sector, academics and organisations as identified/necessary.
    5. To review and revise the structure of the academy to meet the identified objectives.
    6. To ensure that the academy’s principles and ethics, as laid out in the academy’s charter, are applied throughout the structure and services supplied to members.

    ### Academy executive group membership

    A chair and 2 vice chairs will be elected by the members of the strategy group and the tenure will be reviewed on an annual basis.

    Members of the strategy group are co-opted by invitation.

    ### Current executive group membership

    Simon Marshall, Health and Well-being and Substance Misuse Co-commissioning, NOMS (Chair)

    Martin Blake, MTCnovo (Vice Chair)

    Patsy Northern, Business Reform, Department of Health (Vice Chair)

    Janet Cullinan, Academy for Social Justice Commissioning

    Christopher D’Souza, Lambeth Borough of London (London Academy Ambassador)

    Anne Fox, Clinks

    Sally Lewis, Safeguarding and Crinimal Justice professional (South West Academy Ambassador)

    Caroline Marsh, Caroline Marsh Management Solutions (North West, Academy Ambassador)

    Jonathan Martin, Ministry of Justice (Leeds Academy Ambassador)

    ### Vision, Mission and Aims

    ### Privacy Policy
  GOVSPEAK
)
our_governance_page.save!
our_governance_page.document.content_id = "855cc082-22ca-450a-b30d-937ca1caa24d"
our_governance_page.document.save!

# Recreate 'Academy for Justice Commissioning' org, using details derived from live content item for
# https://www.gov.uk/government/organisations/academy-for-justice-commissioning
academy_for_justice_commissioning = Organisation.create!(
  content_id: "4dfe21ee-acfa-4fc1-9513-cc764e814205",
  slug: "academy-for-justice-commissioning",
  name: "Academy for Justice Commissioning",
  organisation_type_key: :other,
  logo_formatted_name: "Academy for Justice Commissioning",
  govuk_status: "closed",
  govuk_closed_status: "changed_name",
  homepage_type: "news",
  political: false,
  analytics_identifier: "OT1025",
  superseding_organisations: [Organisation.find_by(slug: "academy-for-social-justice-commissioning")],
)

[
  "5f5b90be-7631-11e4-a3cb-005056011aef", # https://www.gov.uk/government/organisations/academy-for-justice-commissioning/about
  "5fe5063c-7631-11e4-a3cb-005056011aef", # https://www.gov.uk/government/organisations/academy-for-justice-commissioning/about/membership
].each do |content_id|
  reinstate_corporate_information_page(content_id, academy_for_justice_commissioning)
end
