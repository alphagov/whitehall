document_ids = Document.where(document_type: "WorldwidePriority").pluck(:id)

edition_ids = Edition.where(document_id: document_ids).pluck(:id)

puts "Deleting data (but not tables) for #{edition_ids.count} WorldwidePriority editions and #{document_ids.count} documents"

[
  ClassificationFeaturing,
  ConsultationParticipation,
  EditionAuthor,
  EditionDependency,
  EditionOrganisation,
  EditionRelation,
  EditionRoleAppointment,
  EditionStatisticalDataSet,
  EditionWorldLocation,
  EditionWorldwideOrganisation,
  EditorialRemark,
  FactCheckRequest,
  Image,
  NationInapplicability,
  RecentEditionOpening,
  Response,
  SpecialistSector,
  Unpublishing,
].each do |edition_join_model|
  join_models = edition_join_model.where(edition_id: edition_ids)
  puts "Deleting all #{join_models.count} #{edition_join_model} edition join models"
  join_models.delete_all
end

[
  DocumentCollectionGroupMembership,
  DocumentSource,
  EditionRelation,
  EditionStatisticalDataSet,
  Feature,
].each do |document_join_model|
  join_models = document_join_model.where(document_id: document_ids)
  puts "Deleting all #{join_models.count} #{document_join_model} document join models"
  join_models.delete_all
end

puts "Deleting all edition dependencies"
EditionDependency.where(
  dependable_id: edition_ids,
  dependable_type: "Edition",
).delete_all

puts "Hard-deleting all WorldwidePriority editions, documents, and translations"
Edition.connection.execute(%(
  DELETE d, e, et
  FROM documents d
  JOIN editions e ON e.`document_id` = d.id
  JOIN `edition_translations` et ON et.`edition_id` = e.id
  WHERE d.`document_type` = 'WorldwidePriority';
))
