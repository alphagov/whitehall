# Legacy topical events (the TopicalEvent model, now removed) attached offsite
# links via an OffsiteLinkParent with parent_type "TopicalEvent".
#
# The StandardEdition based topical events (configurable_document_type
# "topical_event") attach them via Edition::Featurable instead, as an
# OffsiteLinkParent with parent_type "Edition" (polymorphic associations store
# the STI base class). Those rows are NOT touched here.
legacy_parents = OffsiteLinkParent.where(parent_type: "TopicalEvent")
legacy_link_ids = legacy_parents.distinct.pluck(:offsite_link_id)

puts "Deleting #{legacy_parents.count} offsite link parents belonging to legacy topical events"

legacy_parents.delete_all

# Delete the offsite links that only belonged to legacy topical events, i.e.
# those now left with no parents. Links that still have another parent
# (organisation, world location news or edition) or that are featured are kept.
orphaned_links = OffsiteLink
  .where(id: legacy_link_ids)
  .where.not(id: OffsiteLinkParent.select(:offsite_link_id))
  .where.not(id: Feature.where.not(offsite_link_id: nil).select(:offsite_link_id))

puts "Deleting #{orphaned_links.count} offsite links that only belonged to legacy topical events"

orphaned_links.delete_all
