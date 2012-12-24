# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121224115459) do

  create_table "attachment_data", :force => true do |t|
    t.string   "carrierwave_file"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "number_of_pages"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachment_sources", :force => true do |t|
    t.integer "attachment_id"
    t.string  "url"
  end

  add_index "attachment_sources", ["attachment_id"], :name => "index_attachment_sources_on_attachment_id"

  create_table "attachments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.boolean  "accessible"
    t.string   "isbn"
    t.string   "unique_reference"
    t.string   "command_paper_number"
    t.string   "order_url"
    t.integer  "price_in_pence"
    t.integer  "attachment_data_id"
  end

  add_index "attachments", ["attachment_data_id"], :name => "index_attachments_on_attachment_data_id"

  create_table "classification_featuring_image_data", :force => true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classification_featurings", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "classification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
    t.integer  "classification_featuring_image_data_id"
    t.string   "alt_text"
  end

  add_index "classification_featurings", ["classification_featuring_image_data_id"], :name => "index_cl_feat_on_edition_org_image_data_id"
  add_index "classification_featurings", ["classification_id"], :name => "index_cl_feat_on_classification_id"
  add_index "classification_featurings", ["edition_id", "classification_id"], :name => "index_cl_feat_on_edition_id_and_classification_id", :unique => true

  create_table "classification_memberships", :force => true do |t|
    t.integer  "classification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "edition_id"
    t.integer  "ordering"
  end

  add_index "classification_memberships", ["classification_id"], :name => "index_classification_memberships_on_classification_id"
  add_index "classification_memberships", ["edition_id"], :name => "index_classification_memberships_on_edition_id"

  create_table "classification_relations", :force => true do |t|
    t.integer  "classification_id",         :null => false
    t.integer  "related_classification_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classification_relations", ["classification_id"], :name => "index_classification_relations_on_classification_id"
  add_index "classification_relations", ["related_classification_id"], :name => "index_classification_relations_on_related_classification_id"

  create_table "classifications", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
    t.string   "state"
    t.integer  "published_edition_count",  :default => 0, :null => false
    t.integer  "published_policies_count", :default => 0, :null => false
    t.string   "type"
    t.string   "carrierwave_image"
    t.string   "logo_alt_text"
  end

  add_index "classifications", ["slug"], :name => "index_classifications_on_slug"

  create_table "consultation_participations", :force => true do |t|
    t.integer  "edition_id"
    t.string   "link_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "consultation_response_form_id"
    t.text     "postal_address"
  end

  add_index "consultation_participations", ["consultation_response_form_id"], :name => "index_cons_participations_on_cons_response_form_id"
  add_index "consultation_participations", ["edition_id"], :name => "index_consultation_participations_on_edition_id"

  create_table "consultation_response_attachments", :force => true do |t|
    t.integer  "response_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "consultation_response_attachments", ["attachment_id"], :name => "index_consultation_response_attachments_on_attachment_id"
  add_index "consultation_response_attachments", ["response_id"], :name => "index_consultation_response_attachments_on_response_id"

  create_table "consultation_response_forms", :force => true do |t|
    t.string   "carrierwave_file"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_numbers", :force => true do |t|
    t.integer  "contact_id"
    t.string   "label"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_numbers", ["contact_id"], :name => "index_contact_numbers_on_contact_id"

  create_table "contacts", :force => true do |t|
    t.integer "organisation_id"
    t.string  "description"
    t.text    "address"
    t.string  "postcode"
    t.decimal "latitude",         :precision => 15, :scale => 10
    t.decimal "longitude",        :precision => 15, :scale => 10
    t.string  "email"
    t.string  "contact_form_url"
  end

  add_index "contacts", ["organisation_id"], :name => "index_contacts_on_organisation_id"

  create_table "corporate_information_page_attachments", :force => true do |t|
    t.integer  "corporate_information_page_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corporate_information_page_attachments", ["attachment_id"], :name => "corporate_information_page_attachments_a_id"
  add_index "corporate_information_page_attachments", ["corporate_information_page_id"], :name => "corporate_information_page_attachments_ci_id"

  create_table "corporate_information_pages", :force => true do |t|
    t.integer  "lock_version"
    t.integer  "organisation_id"
    t.integer  "type_id"
    t.text     "summary"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corporate_information_pages", ["organisation_id", "type_id"], :name => "index_corporate_information_pages_on_organisation_id_and_type_id", :unique => true

  create_table "data_migration_records", :force => true do |t|
    t.string "version"
  end

  add_index "data_migration_records", ["version"], :name => "index_data_migration_records_on_version", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "document_series", :force => true do |t|
    t.string   "name"
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
  end

  add_index "document_series", ["organisation_id"], :name => "index_document_series_on_organisation_id"
  add_index "document_series", ["slug"], :name => "index_document_series_on_slug"

  create_table "document_sources", :force => true do |t|
    t.integer "document_id"
    t.string  "url",         :null => false
    t.integer "import_id"
    t.integer "row_number"
  end

  add_index "document_sources", ["document_id"], :name => "index_document_sources_on_document_id"
  add_index "document_sources", ["url"], :name => "index_document_sources_on_url", :unique => true

  create_table "documents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "document_type"
  end

  add_index "documents", ["slug", "document_type"], :name => "index_documents_on_slug_and_document_type", :unique => true

  create_table "edition_attachments", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_attachments", ["attachment_id"], :name => "index_edition_attachments_on_attachment_id"
  add_index "edition_attachments", ["edition_id"], :name => "index_edition_attachments_on_edition_id"

  create_table "edition_authors", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_authors", ["edition_id"], :name => "index_edition_authors_on_edition_id"
  add_index "edition_authors", ["user_id"], :name => "index_edition_authors_on_user_id"

  create_table "edition_mainstream_categories", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "mainstream_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_mainstream_categories", ["edition_id"], :name => "index_edition_mainstream_categories_on_edition_id"
  add_index "edition_mainstream_categories", ["mainstream_category_id"], :name => "index_edition_mainstream_categories_on_mainstream_category_id"

  create_table "edition_ministerial_roles", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "ministerial_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_ministerial_roles", ["edition_id"], :name => "index_edition_ministerial_roles_on_edition_id"
  add_index "edition_ministerial_roles", ["ministerial_role_id"], :name => "index_edition_ministerial_roles_on_ministerial_role_id"

  create_table "edition_organisation_image_data", :force => true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "edition_organisations", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                           :default => false
    t.integer  "ordering"
    t.integer  "edition_organisation_image_data_id"
    t.string   "alt_text"
  end

  add_index "edition_organisations", ["edition_id", "organisation_id"], :name => "index_edition_organisations_on_edition_id_and_organisation_id", :unique => true
  add_index "edition_organisations", ["edition_organisation_image_data_id"], :name => "index_edition_orgs_on_edition_org_image_data_id"
  add_index "edition_organisations", ["organisation_id"], :name => "index_edition_organisations_on_organisation_id"

  create_table "edition_relations", :force => true do |t|
    t.integer  "edition_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "document_id"
  end

  add_index "edition_relations", ["document_id"], :name => "index_edition_relations_on_document_id"
  add_index "edition_relations", ["edition_id"], :name => "index_edition_relations_on_edition_id"

  create_table "edition_role_appointments", :force => true do |t|
    t.integer "edition_id"
    t.integer "role_appointment_id"
  end

  add_index "edition_role_appointments", ["edition_id"], :name => "index_edition_role_appointments_on_edition_id"
  add_index "edition_role_appointments", ["role_appointment_id"], :name => "index_edition_role_appointments_on_role_appointment_id"

  create_table "edition_statistical_data_sets", :force => true do |t|
    t.integer "edition_id"
    t.integer "document_id"
  end

  add_index "edition_statistical_data_sets", ["document_id"], :name => "index_edition_statistical_data_sets_on_document_id"
  add_index "edition_statistical_data_sets", ["edition_id"], :name => "index_edition_statistical_data_sets_on_edition_id"

  create_table "edition_world_locations", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "world_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",          :default => false
  end

  add_index "edition_world_locations", ["edition_id"], :name => "index_edition_world_locations_on_edition_id"
  add_index "edition_world_locations", ["world_location_id"], :name => "index_edition_world_locations_on_world_location_id"

  create_table "editions", :force => true do |t|
    t.string   "title"
    t.text     "body",                                        :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                                    :default => 0
    t.integer  "document_id"
    t.string   "state",                                                           :default => "draft", :null => false
    t.string   "type"
    t.integer  "role_appointment_id"
    t.string   "location"
    t.date     "delivered_on"
    t.date     "opening_on"
    t.date     "closing_on"
    t.datetime "published_at"
    t.datetime "first_published_at"
    t.date     "publication_date"
    t.text     "notes_to_editors"
    t.text     "summary"
    t.integer  "speech_type_id"
    t.boolean  "stub",                                                            :default => false
    t.text     "change_note"
    t.boolean  "force_published"
    t.boolean  "minor_change",                                                    :default => false
    t.integer  "policy_team_id"
    t.integer  "publication_type_id"
    t.string   "related_mainstream_content_url"
    t.string   "related_mainstream_content_title"
    t.string   "additional_related_mainstream_content_url"
    t.string   "additional_related_mainstream_content_title"
    t.integer  "alternative_format_provider_id"
    t.integer  "document_series_id"
    t.integer  "published_related_publication_count",                             :default => 0,       :null => false
    t.datetime "timestamp_for_sorting"
    t.integer  "primary_mainstream_category_id"
    t.datetime "scheduled_publication"
    t.boolean  "replaces_businesslink",                                           :default => false
    t.boolean  "access_limited"
    t.integer  "published_major_version"
    t.integer  "published_minor_version"
    t.integer  "operational_field_id"
  end

  add_index "editions", ["alternative_format_provider_id"], :name => "index_editions_on_alternative_format_provider_id"
  add_index "editions", ["document_id"], :name => "index_editions_on_document_id"
  add_index "editions", ["document_series_id"], :name => "index_editions_on_document_series_id"
  add_index "editions", ["first_published_at"], :name => "index_editions_on_first_published_at"
  add_index "editions", ["operational_field_id"], :name => "index_editions_on_operational_field_id"
  add_index "editions", ["policy_team_id"], :name => "index_editions_on_policy_team_id"
  add_index "editions", ["primary_mainstream_category_id"], :name => "index_editions_on_primary_mainstream_category_id"
  add_index "editions", ["publication_date"], :name => "index_editions_on_publication_date"
  add_index "editions", ["publication_type_id"], :name => "index_editions_on_publication_type_id"
  add_index "editions", ["role_appointment_id"], :name => "index_editions_on_role_appointment_id"
  add_index "editions", ["speech_type_id"], :name => "index_editions_on_speech_type_id"
  add_index "editions", ["state"], :name => "index_editions_on_state"
  add_index "editions", ["timestamp_for_sorting"], :name => "index_editions_on_timestamp_for_sorting"
  add_index "editions", ["type"], :name => "index_editions_on_type"

  create_table "editorial_remarks", :force => true do |t|
    t.text     "body"
    t.integer  "edition_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editorial_remarks", ["author_id"], :name => "index_editorial_remarks_on_author_id"
  add_index "editorial_remarks", ["edition_id"], :name => "index_editorial_remarks_on_edition_id"

  create_table "fact_check_requests", :force => true do |t|
    t.integer  "edition_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address"
    t.text     "comments"
    t.text     "instructions"
    t.integer  "requestor_id"
  end

  add_index "fact_check_requests", ["edition_id"], :name => "index_fact_check_requests_on_edition_id"
  add_index "fact_check_requests", ["key"], :name => "index_fact_check_requests_on_key", :unique => true
  add_index "fact_check_requests", ["requestor_id"], :name => "index_fact_check_requests_on_requestor_id"

  create_table "fatality_notice_casualties", :force => true do |t|
    t.integer "fatality_notice_id"
    t.text    "personal_details"
  end

  create_table "group_memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_memberships", ["group_id"], :name => "index_group_memberships_on_group_id"
  add_index "group_memberships", ["person_id"], :name => "index_group_memberships_on_person_id"

  create_table "groups", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
  end

  add_index "groups", ["organisation_id"], :name => "index_groups_on_organisation_id"
  add_index "groups", ["slug"], :name => "index_groups_on_slug"

  create_table "image_data", :force => true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "image_data_id"
    t.integer  "edition_id"
    t.string   "alt_text"
    t.text     "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["edition_id"], :name => "index_images_on_edition_id"
  add_index "images", ["image_data_id"], :name => "index_images_on_image_data_id"

  create_table "import_errors", :force => true do |t|
    t.integer  "import_id"
    t.integer  "row_number"
    t.text     "message"
    t.datetime "created_at"
  end

  add_index "import_errors", ["import_id"], :name => "index_import_errors_on_import_id"

  create_table "imports", :force => true do |t|
    t.string   "original_filename"
    t.string   "data_type"
    t.text     "csv_data",           :limit => 2147483647
    t.text     "already_imported"
    t.text     "successful_rows"
    t.integer  "creator_id"
    t.datetime "import_started_at"
    t.datetime "import_finished_at"
    t.integer  "total_rows"
    t.integer  "current_row"
    t.text     "log",                :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "import_enqueued_at"
    t.integer  "organisation_id"
  end

  create_table "mainstream_categories", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.string   "parent_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent_tag"
    t.text     "description"
  end

  add_index "mainstream_categories", ["slug"], :name => "index_mainstream_categories_on_slug", :unique => true

  create_table "nation_inapplicabilities", :force => true do |t|
    t.integer  "nation_id"
    t.integer  "edition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alternative_url"
  end

  add_index "nation_inapplicabilities", ["edition_id"], :name => "index_nation_inapplicabilities_on_edition_id"
  add_index "nation_inapplicabilities", ["nation_id"], :name => "index_nation_inapplicabilities_on_nation_id"

  create_table "operational_fields", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
  end

  add_index "operational_fields", ["slug"], :name => "index_operational_fields_on_slug"

  create_table "organisation_classifications", :force => true do |t|
    t.integer  "organisation_id",                      :null => false
    t.integer  "classification_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
    t.boolean  "lead",              :default => false, :null => false
    t.integer  "lead_ordering"
  end

  add_index "organisation_classifications", ["classification_id"], :name => "index_org_classifications_on_classification_id"
  add_index "organisation_classifications", ["organisation_id", "ordering"], :name => "index_org_classifications_on_organisation_id_and_ordering", :unique => true
  add_index "organisation_classifications", ["organisation_id"], :name => "index_org_classifications_on_organisation_id"

  create_table "organisation_mainstream_links", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "url"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisation_roles", :force => true do |t|
    t.integer  "organisation_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
  end

  add_index "organisation_roles", ["organisation_id"], :name => "index_organisation_roles_on_organisation_id"
  add_index "organisation_roles", ["role_id"], :name => "index_organisation_roles_on_role_id"

  create_table "organisation_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "analytics_prefix"
  end

  create_table "organisational_relationships", :force => true do |t|
    t.integer  "parent_organisation_id"
    t.integer  "child_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisational_relationships", ["child_organisation_id"], :name => "index_organisational_relationships_on_child_organisation_id"
  add_index "organisational_relationships", ["parent_organisation_id"], :name => "index_organisational_relationships_on_parent_organisation_id"

  create_table "organisations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "organisation_type_id"
    t.text     "description"
    t.text     "about_us"
    t.string   "acronym"
    t.string   "url"
    t.text     "logo_formatted_name"
    t.string   "alternative_format_contact_email"
    t.string   "govuk_status",                     :default => "live", :null => false
    t.integer  "organisation_logo_type_id",        :default => 2
    t.string   "analytics_identifier"
    t.boolean  "handles_fatalities",               :default => false
  end

  add_index "organisations", ["organisation_logo_type_id"], :name => "index_organisations_on_organisation_logo_type_id"
  add_index "organisations", ["organisation_type_id"], :name => "index_organisations_on_organisation_type_id"
  add_index "organisations", ["slug"], :name => "index_organisations_on_slug"

  create_table "people", :force => true do |t|
    t.string   "title"
    t.string   "forename"
    t.string   "surname"
    t.string   "letters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "carrierwave_image"
    t.text     "biography"
    t.string   "slug"
    t.boolean  "privy_counsellor",  :default => false
  end

  add_index "people", ["slug"], :name => "index_people_on_slug", :unique => true

  create_table "policy_teams", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
  end

  create_table "recent_edition_openings", :force => true do |t|
    t.integer  "edition_id", :null => false
    t.integer  "editor_id",  :null => false
    t.datetime "created_at", :null => false
  end

  add_index "recent_edition_openings", ["edition_id", "editor_id"], :name => "index_recent_edition_openings_on_edition_id_and_editor_id", :unique => true

  create_table "responses", :force => true do |t|
    t.integer  "edition_id"
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "published_on"
  end

  add_index "responses", ["edition_id"], :name => "index_responses_on_edition_id"

  create_table "role_appointments", :force => true do |t|
    t.integer  "role_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  add_index "role_appointments", ["person_id"], :name => "index_role_appointments_on_person_id"
  add_index "role_appointments", ["role_id"], :name => "index_role_appointments_on_role_id"

  create_table "roles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "type",                       :default => "MinisterialRole", :null => false
    t.boolean  "permanent_secretary",        :default => false
    t.boolean  "cabinet_member",             :default => false,             :null => false
    t.string   "slug"
    t.text     "responsibilities"
    t.boolean  "chief_of_the_defence_staff"
  end

  add_index "roles", ["slug"], :name => "index_roles_on_slug"

  create_table "social_media_accounts", :force => true do |t|
    t.integer  "socialable_id"
    t.integer  "social_media_service_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "socialable_type"
  end

  add_index "social_media_accounts", ["social_media_service_id"], :name => "index_social_media_accounts_on_social_media_service_id"
  add_index "social_media_accounts", ["socialable_id"], :name => "index_social_media_accounts_on_organisation_id"

  create_table "social_media_services", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supporting_page_attachments", :force => true do |t|
    t.integer  "supporting_page_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supporting_page_attachments", ["attachment_id"], :name => "index_supporting_page_attachments_on_attachment_id"
  add_index "supporting_page_attachments", ["supporting_page_id"], :name => "index_supporting_page_attachments_on_supporting_page_id"

  create_table "supporting_pages", :force => true do |t|
    t.integer  "edition_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
    t.string   "slug"
  end

  add_index "supporting_pages", ["edition_id"], :name => "index_supporting_pages_on_edition_id"
  add_index "supporting_pages", ["slug"], :name => "index_supporting_documents_on_slug"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "organisation_id"
    t.string   "uid"
    t.integer  "version"
    t.text     "permissions"
    t.boolean  "remotely_signed_out", :default => false
  end

  add_index "users", ["organisation_id"], :name => "index_users_on_organisation_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "state"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "world_locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "embassy_address"
    t.string   "embassy_telephone"
    t.string   "embassy_email"
    t.string   "slug"
    t.text     "description"
    t.text     "about"
    t.boolean  "active",                 :default => false, :null => false
    t.integer  "world_location_type_id",                    :null => false
  end

  add_index "world_locations", ["slug"], :name => "index_world_locations_on_slug"
  add_index "world_locations", ["world_location_type_id"], :name => "index_world_locations_on_world_location_type_id"

end
