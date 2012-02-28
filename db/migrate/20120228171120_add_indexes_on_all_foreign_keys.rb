class AddIndexesOnAllForeignKeys < ActiveRecord::Migration
  def change
    add_index :contact_numbers, :contact_id
    add_index :contacts, :organisation_id
    add_index :document_attachments, :document_id
    add_index :document_attachments, :attachment_id
    add_index :document_authors, :document_id
    add_index :document_authors, :user_id
    add_index :document_countries, :document_id
    add_index :document_countries, :country_id
    add_index :document_ministerial_roles, :document_id
    add_index :document_ministerial_roles, :ministerial_role_id
    add_index :document_organisations, :document_id
    add_index :document_organisations, :organisation_id
    add_index :document_relations, :document_id
    add_index :document_relations, :document_identity_id
    add_index :documents, :document_identity_id
    add_index :documents, :role_appointment_id
    add_index :documents, :speech_type_id
    add_index :documents, :consultation_document_identity_id
    add_index :editorial_remarks, :document_id
    add_index :editorial_remarks, :author_id
    add_index :fact_check_requests, :document_id
    add_index :fact_check_requests, :requestor_id
    add_index :images, :image_data_id
    add_index :images, :document_id
    add_index :nation_inapplicabilities, :nation_id
    add_index :nation_inapplicabilities, :document_id
    add_index :organisation_policy_topics, :organisation_id
    add_index :organisation_policy_topics, :policy_topic_id
    add_index :organisation_roles, :organisation_id
    add_index :organisation_roles, :role_id
    add_index :organisations, :organisation_type_id
    add_index :policy_topic_memberships, :policy_topic_id
    add_index :policy_topic_memberships, :policy_id
    add_index :policy_topic_relations, :policy_topic_id
    add_index :policy_topic_relations, :related_policy_topic_id
    add_index :role_appointments, :role_id
    add_index :role_appointments, :person_id
    add_index :social_media_accounts, :organisation_id
    add_index :social_media_accounts, :social_media_service_id
    add_index :supporting_page_attachments, :supporting_page_id
    add_index :supporting_page_attachments, :attachment_id
    add_index :supporting_pages, :document_id
    add_index :users, :organisation_id
  end
end
