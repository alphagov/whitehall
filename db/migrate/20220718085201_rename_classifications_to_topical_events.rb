class RenameClassificationsToTopicalEvents < ActiveRecord::Migration[7.0]
  def change
    rename_table :classifications, :topical_events
    rename_table :classification_featurings, :topical_event_featurings
    rename_table :classification_featuring_image_data, :topical_event_featuring_image_data
    rename_table :classification_memberships, :topical_event_memberships
    rename_table :organisation_classifications, :topical_event_organisations

    rename_column :topical_event_featurings, :classification_id, :topical_event_id
    rename_column :topical_event_memberships, :classification_id, :topical_event_id
    rename_column :topical_event_organisations, :classification_id, :topical_event_id

    rename_column :topical_event_featurings, :classification_featuring_image_data_id, :topical_event_featuring_image_data_id

    rename_index :topical_event_organisations, :index_org_classifications_on_organisation_id_and_ordering, :index_topical_event_org_on_organisation_id_and_ordering
    rename_index :topical_event_organisations, :index_org_classifications_on_organisation_id, :index_topical_event_org_on_organisation_id
    rename_index :topical_event_organisations, :index_org_classifications_on_classification_id, :index_topical_event_org_on_topical_event_id

    rename_index :topical_event_featurings, :index_cl_feat_on_edition_id_and_classification_id, :index_topical_event_feat_on_edition_id_and_topical_event_id
    rename_index :topical_event_featurings, :index_cl_feat_on_edition_org_image_data_id, :index_topical_event_feat_on_topical_event_feat_image_data_id
    rename_index :topical_event_featurings, :index_cl_feat_on_classification_id, :index_topical_event_feat_on_topical_event_id
  end
end
