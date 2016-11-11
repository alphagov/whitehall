# Fixes an error with `DocumentCollection` sync checks with `document_id = 256174`
# This collection contains a `Document` with an id of `258249` which managed to get
# itself into a state where the `Edition` (383738) had a state of `withdrawn` but
# there was no corresponding record in the `Unpublishings` table. In additon the
# Document has a second `Edition` (with `edition_id` 494737) with a state of `deleted`.
# Browsing the document
# (http://www.gov.uk/government/publications/part-i-claim-a66-long-newton-grade-separated-junction)
# showed a page that stated "Sorry, we're experiencing technical difficulties".
#
# Shilpa contacted the publisher (Paul Knights of Highways England) and he confirmed
# that the document could be unpublished.
#
# To do this, we create a record in the `Unpublishings` table for the `withdrawn`
# edition. This fixes the front end "technical difficulties" notice by displaying
# a proper withdrawn notification and also sorts out our sync checks
Unpublishing.create(
  edition_id: 383738,
  unpublishing_reason_id: 5,
  explanation: "This scheme has been completed and no further claims are permissible",
  document_type: "Publication",
  slug: "part-i-claim-a66-long-newton-grade-separated-junction"
)
