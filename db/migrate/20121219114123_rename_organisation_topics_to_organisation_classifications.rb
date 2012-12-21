class RenameOrganisationTopicsToOrganisationClassifications < ActiveRecord::Migration
  def change
    rename_table :organisation_topics, :organisation_classifications

    rename_index :organisation_classifications, "index_organisation_policy_topics_on_policy_topic_id", "index_org_classifications_on_classification_id"
    rename_index :organisation_classifications, "index_organisation_topics_on_organisation_id_and_ordering", "index_org_classifications_on_organisation_id_and_ordering"
    rename_index :organisation_classifications, "index_organisation_policy_topics_on_organisation_id", "index_org_classifications_on_organisation_id"
  end
end
