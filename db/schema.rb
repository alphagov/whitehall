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

ActiveRecord::Schema.define(:version => 20130906093144) do

  create_table "about_pages", :force => true do |t|
    t.integer  "topical_event_id"
    t.string   "name"
    t.text     "summary"
    t.text     "body"
    t.string   "read_more_link_text"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "access_and_opening_times", :force => true do |t|
    t.text     "body"
    t.string   "accessible_type"
    t.integer  "accessible_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_and_opening_times", ["accessible_id", "accessible_type"], :name => "accessible_index"

  create_table "attachment_data", :force => true do |t|
    t.string   "carrierwave_file"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "number_of_pages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "replaced_by_id"
  end

  add_index "attachment_data", ["replaced_by_id"], :name => "index_attachment_data_on_replaced_by_id"

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
    t.integer  "ordering"
    t.string   "hoc_paper_number"
    t.string   "parliamentary_session"
    t.boolean  "unnumbered_command_paper"
    t.boolean  "unnumbered_hoc_paper"
  end

  add_index "attachments", ["attachment_data_id"], :name => "index_attachments_on_attachment_data_id"
  add_index "attachments", ["ordering"], :name => "index_attachments_on_ordering"

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
    t.date     "start_date"
    t.date     "end_date"
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

  create_table "consultation_response_form_data", :force => true do |t|
    t.string   "carrierwave_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consultation_response_forms", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "consultation_response_form_data_id"
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
    t.decimal "latitude",         :precision => 15, :scale => 10
    t.decimal "longitude",        :precision => 15, :scale => 10
    t.string  "email"
    t.string  "contact_form_url"
    t.integer "contactable_id"
    t.string  "contactable_type"
    t.string  "title"
    t.text    "comments"
    t.string  "recipient"
    t.text    "street_address"
    t.string  "locality"
    t.string  "region"
    t.string  "postal_code"
    t.integer "country_id"
    t.integer "contact_type_id",                                  :null => false
  end

  add_index "contacts", ["contact_type_id"], :name => "index_contacts_on_contact_type_id"
  add_index "contacts", ["contactable_id", "contactable_type"], :name => "index_contacts_on_contactable_id_and_contactable_type"

  create_table "corporate_information_page_attachments", :force => true do |t|
    t.integer  "corporate_information_page_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corporate_information_page_attachments", ["attachment_id"], :name => "corporate_information_page_attachments_a_id"
  add_index "corporate_information_page_attachments", ["corporate_information_page_id"], :name => "corporate_information_page_attachments_ci_id"

  create_table "corporate_information_page_translations", :force => true do |t|
    t.integer  "corporate_information_page_id"
    t.string   "locale"
    t.text     "summary"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "corporate_information_page_translations", ["corporate_information_page_id"], :name => "index_f7e11e733407448d5e73391b45406ba2c3a87a54"
  add_index "corporate_information_page_translations", ["locale"], :name => "index_corporate_information_page_translations_on_locale"

  create_table "corporate_information_pages", :force => true do |t|
    t.integer  "lock_version"
    t.integer  "organisation_id"
    t.integer  "type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "organisation_type"
  end

  add_index "corporate_information_pages", ["organisation_id", "organisation_type", "type_id"], :name => "index_corporate_information_pages_on_polymorphic_columns", :unique => true

  create_table "data_migration_records", :force => true do |t|
    t.string "version"
  end

  add_index "data_migration_records", ["version"], :name => "index_data_migration_records_on_version", :unique => true

  create_table "default_news_organisation_image_data", :force => true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "state",           :default => "current"
    t.string   "summary"
  end

  add_index "document_series", ["organisation_id"], :name => "index_document_series_on_organisation_id"
  add_index "document_series", ["slug"], :name => "index_document_series_on_slug"

  create_table "document_series_group_memberships", :force => true do |t|
    t.integer  "document_id"
    t.integer  "document_series_group_id"
    t.integer  "ordering"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "document_series_group_memberships", ["document_id"], :name => "index_document_series_group_memberships_on_document_id"
  add_index "document_series_group_memberships", ["document_series_group_id", "ordering"], :name => "index_document_series_memberships_on_group_id_and_ordering"

  create_table "document_series_groups", :force => true do |t|
    t.integer  "document_series_id"
    t.string   "heading"
    t.text     "body"
    t.integer  "ordering"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "document_series_groups", ["document_series_id", "ordering"], :name => "index_document_series_groups_on_document_series_id_and_ordering"

  create_table "document_series_memberships", :force => true do |t|
    t.integer  "document_series_id"
    t.integer  "document_id"
    t.integer  "ordering"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "document_series_memberships", ["document_id", "document_series_id"], :name => "index_document_series_memberships_on_document_and_series_id"
  add_index "document_series_memberships", ["document_series_id", "ordering"], :name => "index_document_series_memberships_on_series_id_and_ordering"

  create_table "document_sources", :force => true do |t|
    t.integer "document_id"
    t.string  "url",                           :null => false
    t.integer "import_id"
    t.integer "row_number"
    t.string  "locale",      :default => "en"
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

  create_table "edition_document_series", :force => true do |t|
    t.integer "edition_id",         :null => false
    t.integer "document_series_id", :null => false
  end

  add_index "edition_document_series", ["edition_id", "document_series_id"], :name => "index_edition_document_series", :unique => true

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
    t.boolean  "lead",                               :default => false, :null => false
    t.integer  "lead_ordering"
  end

  add_index "edition_organisations", ["edition_id", "organisation_id"], :name => "index_edition_organisations_on_edition_id_and_organisation_id", :unique => true
  add_index "edition_organisations", ["edition_organisation_image_data_id"], :name => "index_edition_orgs_on_edition_org_image_data_id"
  add_index "edition_organisations", ["organisation_id"], :name => "index_edition_organisations_on_organisation_id"

  create_table "edition_policy_groups", :force => true do |t|
    t.integer "edition_id"
    t.integer "policy_group_id"
  end

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

  create_table "edition_translations", :force => true do |t|
    t.integer  "edition_id"
    t.string   "locale"
    t.string   "title"
    t.text     "summary"
    t.text     "body",       :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_translations", ["edition_id"], :name => "index_edition_translations_on_edition_id"
  add_index "edition_translations", ["locale"], :name => "index_edition_translations_on_locale"

  create_table "edition_world_location_image_data", :force => true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "edition_world_locations", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "world_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                             :default => false
    t.integer  "ordering"
    t.integer  "edition_world_location_image_data_id"
    t.string   "alt_text"
  end

  add_index "edition_world_locations", ["edition_id", "world_location_id"], :name => "idx_edition_world_locations_on_edition_and_world_location_ids", :unique => true
  add_index "edition_world_locations", ["edition_id"], :name => "index_edition_world_locations_on_edition_id"
  add_index "edition_world_locations", ["edition_world_location_image_data_id"], :name => "idx_edition_world_locs_on_edition_world_location_image_data_id"
  add_index "edition_world_locations", ["world_location_id"], :name => "index_edition_world_locations_on_world_location_id"

  create_table "edition_worldwide_organisations", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "worldwide_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_worldwide_organisations", ["edition_id"], :name => "index_edition_worldwide_orgs_on_edition_id"
  add_index "edition_worldwide_organisations", ["worldwide_organisation_id"], :name => "index_edition_worldwide_orgs_on_worldwide_organisation_id"

  create_table "editions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                :default => 0
    t.integer  "document_id"
    t.string   "state",                                       :default => "draft", :null => false
    t.string   "type"
    t.integer  "role_appointment_id"
    t.string   "location"
    t.datetime "delivered_on"
    t.date     "opening_on"
    t.date     "closing_on"
    t.datetime "major_change_published_at"
    t.datetime "first_published_at"
    t.integer  "speech_type_id"
    t.boolean  "stub",                                        :default => false
    t.text     "change_note"
    t.boolean  "force_published"
    t.boolean  "minor_change",                                :default => false
    t.integer  "publication_type_id"
    t.string   "related_mainstream_content_url"
    t.string   "related_mainstream_content_title"
    t.string   "additional_related_mainstream_content_url"
    t.string   "additional_related_mainstream_content_title"
    t.integer  "alternative_format_provider_id"
    t.integer  "published_related_publication_count",         :default => 0,       :null => false
    t.datetime "public_timestamp"
    t.integer  "primary_mainstream_category_id"
    t.datetime "scheduled_publication"
    t.boolean  "replaces_businesslink",                       :default => false
    t.boolean  "access_limited",                                                   :null => false
    t.integer  "published_major_version"
    t.integer  "published_minor_version"
    t.integer  "operational_field_id"
    t.text     "roll_call_introduction"
    t.integer  "news_article_type_id"
    t.boolean  "relevant_to_local_government",                :default => false
    t.string   "person_override"
    t.string   "locale",                                      :default => "en",    :null => false
    t.boolean  "external",                                    :default => false
    t.string   "external_url"
  end

  add_index "editions", ["alternative_format_provider_id"], :name => "index_editions_on_alternative_format_provider_id"
  add_index "editions", ["document_id"], :name => "index_editions_on_document_id"
  add_index "editions", ["first_published_at"], :name => "index_editions_on_first_published_at"
  add_index "editions", ["locale"], :name => "index_editions_on_locale"
  add_index "editions", ["operational_field_id"], :name => "index_editions_on_operational_field_id"
  add_index "editions", ["primary_mainstream_category_id"], :name => "index_editions_on_primary_mainstream_category_id"
  add_index "editions", ["public_timestamp", "document_id"], :name => "index_editions_on_public_timestamp_and_document_id"
  add_index "editions", ["public_timestamp"], :name => "index_editions_on_public_timestamp"
  add_index "editions", ["publication_type_id"], :name => "index_editions_on_publication_type_id"
  add_index "editions", ["role_appointment_id"], :name => "index_editions_on_role_appointment_id"
  add_index "editions", ["speech_type_id"], :name => "index_editions_on_speech_type_id"
  add_index "editions", ["state", "type"], :name => "index_editions_on_state_and_type"
  add_index "editions", ["state"], :name => "index_editions_on_state"
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

  create_table "email_curation_queue_items", :force => true do |t|
    t.integer  "edition_id",        :null => false
    t.string   "title"
    t.text     "summary"
    t.datetime "notification_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_curation_queue_items", ["edition_id"], :name => "index_email_curation_queue_items_on_edition_id"

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

  create_table "feature_lists", :force => true do |t|
    t.integer  "featurable_id"
    t.string   "featurable_type"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_lists", ["featurable_id", "featurable_type", "locale"], :name => "featurable_lists_unique_locale_per_featurable", :unique => true

  create_table "featured_items", :force => true do |t|
    t.integer  "item_id",                              :null => false
    t.string   "item_type",                            :null => false
    t.integer  "featured_topics_and_policies_list_id"
    t.integer  "ordering"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  add_index "featured_items", ["featured_topics_and_policies_list_id", "ordering"], :name => "idx_featured_items_on_featured_ts_and_ps_list_id_and_ordering"
  add_index "featured_items", ["featured_topics_and_policies_list_id"], :name => "index_featured_items_on_featured_topics_and_policies_list_id"
  add_index "featured_items", ["item_id", "item_type"], :name => "index_featured_items_on_item_id_and_item_type"

  create_table "featured_topics_and_policies_lists", :force => true do |t|
    t.integer  "organisation_id",                             :null => false
    t.text     "summary"
    t.boolean  "link_to_filtered_policies", :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_topics_and_policies_lists", ["organisation_id"], :name => "index_featured_topics_and_policies_lists_on_organisation_id"

  create_table "features", :force => true do |t|
    t.integer  "document_id"
    t.integer  "feature_list_id"
    t.string   "carrierwave_image"
    t.string   "alt_text"
    t.integer  "ordering"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "topical_event_id"
  end

  add_index "features", ["document_id"], :name => "index_features_on_document_id"
  add_index "features", ["feature_list_id", "ordering"], :name => "index_features_on_feature_list_id_and_ordering", :unique => true
  add_index "features", ["feature_list_id"], :name => "index_features_on_feature_list_id"
  add_index "features", ["ordering"], :name => "index_features_on_ordering"

  create_table "financial_reports", :force => true do |t|
    t.integer "organisation_id"
    t.integer "funding",         :limit => 8
    t.integer "spending",        :limit => 8
    t.integer "year"
  end

  add_index "financial_reports", ["organisation_id", "year"], :name => "index_financial_reports_on_organisation_id_and_year", :unique => true
  add_index "financial_reports", ["organisation_id"], :name => "index_financial_reports_on_organisation_id"
  add_index "financial_reports", ["year"], :name => "index_financial_reports_on_year"

  create_table "force_publication_attempts", :force => true do |t|
    t.integer  "import_id"
    t.integer  "total_documents"
    t.integer  "successful_documents"
    t.datetime "enqueued_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "log",                  :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "force_publication_attempts", ["import_id"], :name => "index_force_publication_attempts_on_import_id"

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

  create_table "historical_account_roles", :force => true do |t|
    t.integer  "role_id"
    t.integer  "historical_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "historical_account_roles", ["historical_account_id"], :name => "index_historical_account_roles_on_historical_account_id"
  add_index "historical_account_roles", ["role_id"], :name => "index_historical_account_roles_on_role_id"

  create_table "historical_accounts", :force => true do |t|
    t.integer  "person_id"
    t.text     "summary"
    t.text     "body"
    t.string   "born"
    t.string   "died"
    t.text     "major_acts"
    t.text     "interesting_facts"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "political_party_ids"
  end

  add_index "historical_accounts", ["person_id"], :name => "index_historical_accounts_on_person_id"

  create_table "home_page_list_items", :force => true do |t|
    t.integer  "home_page_list_id", :null => false
    t.integer  "item_id",           :null => false
    t.string   "item_type",         :null => false
    t.integer  "ordering"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_page_list_items", ["home_page_list_id", "ordering"], :name => "index_home_page_list_items_on_home_page_list_id_and_ordering"
  add_index "home_page_list_items", ["home_page_list_id"], :name => "index_home_page_list_items_on_home_page_list_id"
  add_index "home_page_list_items", ["item_id", "item_type"], :name => "index_home_page_list_items_on_item_id_and_item_type"

  create_table "home_page_lists", :force => true do |t|
    t.integer  "owner_id",   :null => false
    t.string   "owner_type", :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_page_lists", ["owner_id", "owner_type", "name"], :name => "index_home_page_lists_on_owner_id_and_owner_type_and_name", :unique => true

  create_table "html_versions", :force => true do |t|
    t.integer  "edition_id"
    t.string   "title"
    t.text     "body",              :limit => 2147483647
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "manually_numbered",                       :default => false
  end

  add_index "html_versions", ["slug"], :name => "index_html_versions_on_slug"

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

  create_table "import_logs", :force => true do |t|
    t.integer  "import_id"
    t.integer  "row_number"
    t.string   "level"
    t.text     "message"
    t.datetime "created_at"
  end

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

  create_table "mainstream_links", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "linkable_type"
    t.integer  "linkable_id"
  end

  add_index "mainstream_links", ["linkable_id", "linkable_type"], :name => "index_mainstream_links_on_linkable_id_and_linkable_type"
  add_index "mainstream_links", ["linkable_type"], :name => "index_mainstream_links_on_linkable_type"

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

  create_table "organisation_mainstream_categories", :force => true do |t|
    t.integer  "organisation_id",                        :null => false
    t.integer  "mainstream_category_id",                 :null => false
    t.integer  "ordering",               :default => 99, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisation_mainstream_categories", ["mainstream_category_id"], :name => "index_org_mainstream_cats_on_mainstream_cat_id"
  add_index "organisation_mainstream_categories", ["organisation_id", "mainstream_category_id"], :name => "index_org_mainstream_cats_on_org_id_and_mainstream_cat_id", :unique => true
  add_index "organisation_mainstream_categories", ["organisation_id"], :name => "index_org_mainstream_cats_on_org_id"

  create_table "organisation_mainstream_links", :force => true do |t|
    t.integer "organisation_id"
    t.integer "mainstream_link_id"
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

  create_table "organisation_translations", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "locale"
    t.string   "name"
    t.text     "logo_formatted_name"
    t.string   "acronym"
    t.text     "description"
    t.text     "about_us"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisation_translations", ["locale"], :name => "index_organisation_translations_on_locale"
  add_index "organisation_translations", ["name"], :name => "index_organisation_translations_on_name"
  add_index "organisation_translations", ["organisation_id"], :name => "index_organisation_translations_on_organisation_id"

  create_table "organisation_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "analytics_prefix"
  end

  add_index "organisation_types", ["name"], :name => "index_organisation_types_on_name"

  create_table "organisational_relationships", :force => true do |t|
    t.integer  "parent_organisation_id"
    t.integer  "child_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisational_relationships", ["child_organisation_id"], :name => "index_organisational_relationships_on_child_organisation_id"
  add_index "organisational_relationships", ["parent_organisation_id"], :name => "index_organisational_relationships_on_parent_organisation_id"

  create_table "organisations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "organisation_type_id"
    t.string   "url"
    t.string   "alternative_format_contact_email"
    t.string   "govuk_status",                            :default => "live", :null => false
    t.integer  "organisation_logo_type_id",               :default => 2
    t.string   "analytics_identifier"
    t.boolean  "handles_fatalities",                      :default => false
    t.integer  "important_board_members",                 :default => 1
    t.integer  "default_news_organisation_image_data_id"
    t.datetime "closed_at"
    t.integer  "organisation_brand_colour_id"
    t.boolean  "ocpa_regulated"
    t.boolean  "public_meetings"
    t.boolean  "public_minutes"
    t.boolean  "register_of_interests"
    t.boolean  "regulatory_function"
    t.string   "logo"
  end

  add_index "organisations", ["default_news_organisation_image_data_id"], :name => "index_organisations_on_default_news_organisation_image_data_id"
  add_index "organisations", ["id", "organisation_type_id"], :name => "index_organisations_on_id_and_organisation_type_id"
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
    t.string   "slug"
    t.boolean  "privy_counsellor",  :default => false
  end

  add_index "people", ["slug"], :name => "index_people_on_slug", :unique => true

  create_table "person_translations", :force => true do |t|
    t.integer  "person_id"
    t.string   "locale"
    t.text     "biography"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "person_translations", ["locale"], :name => "index_person_translations_on_locale"
  add_index "person_translations", ["person_id"], :name => "index_person_translations_on_person_id"

  create_table "policy_group_attachments", :force => true do |t|
    t.integer  "policy_group_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "policy_groups", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.string   "type"
    t.text     "summary"
    t.string   "slug"
  end

  add_index "policy_groups", ["slug"], :name => "index_policy_groups_on_slug"

  create_table "promotional_feature_items", :force => true do |t|
    t.integer  "promotional_feature_id"
    t.text     "summary"
    t.string   "image"
    t.string   "image_alt_text"
    t.string   "title"
    t.string   "title_url"
    t.boolean  "double_width",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_feature_items", ["promotional_feature_id"], :name => "index_promotional_feature_items_on_promotional_feature_id"

  create_table "promotional_feature_links", :force => true do |t|
    t.integer  "promotional_feature_item_id"
    t.string   "url"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_feature_links", ["promotional_feature_item_id"], :name => "index_promotional_feature_links_on_promotional_feature_item_id"

  create_table "promotional_features", :force => true do |t|
    t.integer  "organisation_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_features", ["organisation_id"], :name => "index_promotional_features_on_organisation_id"

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
    t.string   "type"
  end

  add_index "responses", ["edition_id", "type"], :name => "index_responses_on_edition_id_and_type"
  add_index "responses", ["edition_id"], :name => "index_responses_on_edition_id"

  create_table "role_appointments", :force => true do |t|
    t.integer  "role_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  add_index "role_appointments", ["ended_at"], :name => "index_role_appointments_on_ended_at"
  add_index "role_appointments", ["person_id"], :name => "index_role_appointments_on_person_id"
  add_index "role_appointments", ["role_id"], :name => "index_role_appointments_on_role_id"

  create_table "role_translations", :force => true do |t|
    t.integer  "role_id"
    t.string   "locale"
    t.string   "name"
    t.text     "responsibilities"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_translations", ["locale"], :name => "index_role_translations_on_locale"
  add_index "role_translations", ["name"], :name => "index_role_translations_on_name"
  add_index "role_translations", ["role_id"], :name => "index_role_translations_on_role_id"

  create_table "roles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                         :default => "MinisterialRole", :null => false
    t.boolean  "permanent_secretary",          :default => false
    t.boolean  "cabinet_member",               :default => false,             :null => false
    t.string   "slug"
    t.boolean  "chief_of_the_defence_staff",   :default => false,             :null => false
    t.integer  "whip_organisation_id"
    t.integer  "seniority",                    :default => 100
    t.integer  "attends_cabinet_type_id"
    t.integer  "role_payment_type_id"
    t.boolean  "supports_historical_accounts", :default => false,             :null => false
    t.integer  "whip_ordering",                :default => 100
  end

  add_index "roles", ["attends_cabinet_type_id"], :name => "index_roles_on_attends_cabinet_type_id"
  add_index "roles", ["slug"], :name => "index_roles_on_slug"
  add_index "roles", ["supports_historical_accounts"], :name => "index_roles_on_supports_historical_accounts"

  create_table "social_media_accounts", :force => true do |t|
    t.integer  "socialable_id"
    t.integer  "social_media_service_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "socialable_type"
    t.string   "title"
  end

  add_index "social_media_accounts", ["social_media_service_id"], :name => "index_social_media_accounts_on_social_media_service_id"
  add_index "social_media_accounts", ["socialable_id"], :name => "index_social_media_accounts_on_organisation_id"

  create_table "social_media_services", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsorships", :force => true do |t|
    t.integer  "organisation_id"
    t.integer  "worldwide_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsorships", ["organisation_id", "worldwide_organisation_id"], :name => "unique_sponsorships", :unique => true
  add_index "sponsorships", ["worldwide_organisation_id"], :name => "index_sponsorships_on_worldwide_organisation_id"

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

  create_table "take_part_pages", :force => true do |t|
    t.string   "title",                                 :null => false
    t.string   "slug",                                  :null => false
    t.string   "summary",                               :null => false
    t.text     "body",              :limit => 16777215, :null => false
    t.string   "carrierwave_image"
    t.string   "image_alt_text"
    t.integer  "ordering",                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "take_part_pages", ["ordering"], :name => "index_take_part_pages_on_ordering"
  add_index "take_part_pages", ["slug"], :name => "index_take_part_pages_on_slug", :unique => true

  create_table "unpublishings", :force => true do |t|
    t.integer  "edition_id"
    t.integer  "unpublishing_reason_id"
    t.text     "explanation"
    t.text     "alternative_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
    t.string   "slug"
    t.boolean  "redirect",               :default => false
  end

  add_index "unpublishings", ["edition_id"], :name => "index_unpublishings_on_edition_id"
  add_index "unpublishings", ["unpublishing_reason_id"], :name => "index_unpublishings_on_unpublishing_reason_id"

  create_table "user_world_locations", :force => true do |t|
    t.integer "user_id"
    t.integer "world_location_id"
  end

  add_index "user_world_locations", ["user_id", "world_location_id"], :name => "index_user_world_locations_on_user_id_and_world_location_id", :unique => true

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

  create_table "world_location_mainstream_links", :force => true do |t|
    t.integer "world_location_id"
    t.integer "mainstream_link_id"
  end

  create_table "world_location_translations", :force => true do |t|
    t.integer  "world_location_id"
    t.string   "locale"
    t.string   "name"
    t.text     "mission_statement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  add_index "world_location_translations", ["locale"], :name => "index_world_location_translations_on_locale"
  add_index "world_location_translations", ["world_location_id"], :name => "index_world_location_translations_on_world_location_id"

  create_table "world_locations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.boolean  "active",                              :default => false, :null => false
    t.integer  "world_location_type_id",                                 :null => false
    t.string   "iso2",                   :limit => 2
  end

  add_index "world_locations", ["iso2"], :name => "index_world_locations_on_iso2", :unique => true
  add_index "world_locations", ["slug"], :name => "index_world_locations_on_slug"
  add_index "world_locations", ["world_location_type_id"], :name => "index_world_locations_on_world_location_type_id"

  create_table "worldwide_office_worldwide_services", :force => true do |t|
    t.integer  "worldwide_office_id",  :null => false
    t.integer  "worldwide_service_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worldwide_offices", :force => true do |t|
    t.integer  "worldwide_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worldwide_office_type_id",  :null => false
    t.string   "slug"
  end

  add_index "worldwide_offices", ["slug"], :name => "index_worldwide_offices_on_slug"
  add_index "worldwide_offices", ["worldwide_organisation_id"], :name => "index_worldwide_offices_on_worldwide_organisation_id"

  create_table "worldwide_organisation_roles", :force => true do |t|
    t.integer  "worldwide_organisation_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_roles", ["role_id"], :name => "index_worldwide_org_roles_on_role_id"
  add_index "worldwide_organisation_roles", ["worldwide_organisation_id"], :name => "index_worldwide_org_roles_on_worldwide_organisation_id"

  create_table "worldwide_organisation_translations", :force => true do |t|
    t.integer  "worldwide_organisation_id"
    t.string   "locale"
    t.string   "name"
    t.text     "summary"
    t.text     "description"
    t.text     "services"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_translations", ["locale"], :name => "index_worldwide_org_translations_on_locale"
  add_index "worldwide_organisation_translations", ["worldwide_organisation_id"], :name => "index_worldwide_org_translations_on_worldwide_organisation_id"

  create_table "worldwide_organisation_world_locations", :force => true do |t|
    t.integer  "worldwide_organisation_id"
    t.integer  "world_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_world_locations", ["world_location_id"], :name => "index_worldwide_org_world_locations_on_world_location_id"
  add_index "worldwide_organisation_world_locations", ["worldwide_organisation_id"], :name => "index_worldwide_org_world_locations_on_worldwide_organisation_id"

  create_table "worldwide_organisations", :force => true do |t|
    t.string   "url"
    t.string   "slug"
    t.string   "logo_formatted_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "main_office_id"
    t.integer  "default_news_organisation_image_data_id"
  end

  add_index "worldwide_organisations", ["default_news_organisation_image_data_id"], :name => "index_worldwide_organisations_on_image_data_id"
  add_index "worldwide_organisations", ["slug"], :name => "index_worldwide_organisations_on_slug", :unique => true

  create_table "worldwide_services", :force => true do |t|
    t.string   "name",            :null => false
    t.integer  "service_type_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
