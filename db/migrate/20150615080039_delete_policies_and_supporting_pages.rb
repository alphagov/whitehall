class DeletePoliciesAndSupportingPages < ActiveRecord::Migration
  def up
    document_ids = Document
                     .where(document_type: %w[SupportingPage Policy])
                     .pluck(:id)

    edition_ids = Edition
                    .where(document_id: document_ids)
                    .pluck(:id)

    puts "Deleting data (but not tables) for #{edition_ids.count} policy and supporting page editions and #{document_ids.count} documents"

    [
      ClassificationFeaturing,
      ConsultationParticipation,
      EditionAuthor,
      EditionDependency,
      EditionMainstreamCategory,
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

    db = Edition.connection

    %w[
      editioned_supporting_page_mappings
      featured_items
      featured_topics_and_policies_lists
      supporting_page_redirects
    ].each do |table|
      puts "Deleting all #{table}"
      db.delete("DELETE FROM #{table}")
    end

    puts "Deleting all editions"
    Edition.find(edition_ids).each do |edition|
      Whitehall.edition_services.deleter(edition).perform!
    end
  end
end

class Policy < Edition; end
class SupportingPage < Edition; end
