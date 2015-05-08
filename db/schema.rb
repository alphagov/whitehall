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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150430084915) do

  create_table "about_pages", force: true do |t|
    t.integer  "topical_event_id"
    t.string   "name"
    t.text     "summary"
    t.text     "body"
    t.string   "read_more_link_text"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "access_and_opening_times", force: true do |t|
    t.text     "body"
    t.string   "accessible_type"
    t.integer  "accessible_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_and_opening_times", ["accessible_id", "accessible_type"], name: "accessible_index", using: :btree

  create_table "attachment_data", force: true do |t|
    t.string   "carrierwave_file"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "number_of_pages"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "replaced_by_id"
  end

  add_index "attachment_data", ["replaced_by_id"], name: "index_attachment_data_on_replaced_by_id", using: :btree

  create_table "attachment_sources", force: true do |t|
    t.integer "attachment_id"
    t.string  "url"
  end

  add_index "attachment_sources", ["attachment_id"], name: "index_attachment_sources_on_attachment_id", using: :btree

  create_table "attachments", force: true do |t|
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
    t.integer  "ordering",                 null: false
    t.string   "hoc_paper_number"
    t.string   "parliamentary_session"
    t.boolean  "unnumbered_command_paper"
    t.boolean  "unnumbered_hoc_paper"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "type"
    t.string   "slug"
    t.string   "locale"
    t.string   "external_url"
  end

  add_index "attachments", ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type", using: :btree
  add_index "attachments", ["attachable_type", "attachable_id", "ordering"], name: "no_duplicate_attachment_orderings", unique: true, using: :btree
  add_index "attachments", ["attachment_data_id"], name: "index_attachments_on_attachment_data_id", using: :btree
  add_index "attachments", ["ordering"], name: "index_attachments_on_ordering", using: :btree

  create_table "classification_featuring_image_data", force: true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classification_featurings", force: true do |t|
    t.integer  "edition_id"
    t.integer  "classification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
    t.integer  "classification_featuring_image_data_id"
    t.string   "alt_text"
    t.integer  "offsite_link_id"
  end

  add_index "classification_featurings", ["classification_featuring_image_data_id"], name: "index_cl_feat_on_edition_org_image_data_id", using: :btree
  add_index "classification_featurings", ["classification_id"], name: "index_cl_feat_on_classification_id", using: :btree
  add_index "classification_featurings", ["edition_id", "classification_id"], name: "index_cl_feat_on_edition_id_and_classification_id", unique: true, using: :btree
  add_index "classification_featurings", ["offsite_link_id"], name: "index_classification_featurings_on_offsite_link_id", using: :btree

  create_table "classification_memberships", force: true do |t|
    t.integer  "classification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "edition_id"
    t.integer  "ordering"
  end

  add_index "classification_memberships", ["classification_id"], name: "index_classification_memberships_on_classification_id", using: :btree
  add_index "classification_memberships", ["edition_id"], name: "index_classification_memberships_on_edition_id", using: :btree

  create_table "classification_policies", force: true do |t|
    t.integer  "classification_id"
    t.string   "policy_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classification_policies", ["classification_id"], name: "index_classification_policies_on_classification_id", using: :btree
  add_index "classification_policies", ["policy_content_id"], name: "index_classification_policies_on_policy_content_id", using: :btree

  create_table "classification_relations", force: true do |t|
    t.integer  "classification_id",         null: false
    t.integer  "related_classification_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classification_relations", ["classification_id"], name: "index_classification_relations_on_classification_id", using: :btree
  add_index "classification_relations", ["related_classification_id"], name: "index_classification_relations_on_related_classification_id", using: :btree

  create_table "classifications", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
    t.string   "state"
    t.string   "type"
    t.string   "carrierwave_image"
    t.string   "logo_alt_text"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "classifications", ["slug"], name: "index_classifications_on_slug", using: :btree

  create_table "consultation_participations", force: true do |t|
    t.integer  "edition_id"
    t.string   "link_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "consultation_response_form_id"
    t.text     "postal_address"
  end

  add_index "consultation_participations", ["consultation_response_form_id"], name: "index_cons_participations_on_cons_response_form_id", using: :btree
  add_index "consultation_participations", ["edition_id"], name: "index_consultation_participations_on_edition_id", using: :btree

  create_table "consultation_response_form_data", force: true do |t|
    t.string   "carrierwave_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consultation_response_forms", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "consultation_response_form_data_id"
  end

  create_table "contact_number_translations", force: true do |t|
    t.integer  "contact_number_id"
    t.string   "locale"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "label"
    t.string   "number"
  end

  add_index "contact_number_translations", ["contact_number_id"], name: "index_contact_number_translations_on_contact_number_id", using: :btree
  add_index "contact_number_translations", ["locale"], name: "index_contact_number_translations_on_locale", using: :btree

  create_table "contact_numbers", force: true do |t|
    t.integer  "contact_id"
    t.string   "label"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_numbers", ["contact_id"], name: "index_contact_numbers_on_contact_id", using: :btree

  create_table "contact_translations", force: true do |t|
    t.integer  "contact_id"
    t.string   "locale"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "title"
    t.text     "comments"
    t.string   "recipient"
    t.text     "street_address"
    t.string   "locality"
    t.string   "region"
    t.string   "email"
    t.string   "contact_form_url"
  end

  add_index "contact_translations", ["contact_id"], name: "index_contact_translations_on_contact_id", using: :btree
  add_index "contact_translations", ["locale"], name: "index_contact_translations_on_locale", using: :btree

  create_table "contacts", force: true do |t|
    t.decimal "latitude",         precision: 15, scale: 10
    t.decimal "longitude",        precision: 15, scale: 10
    t.integer "contactable_id"
    t.string  "contactable_type"
    t.string  "postal_code"
    t.integer "country_id"
    t.integer "contact_type_id",                            null: false
  end

  add_index "contacts", ["contact_type_id"], name: "index_contacts_on_contact_type_id", using: :btree
  add_index "contacts", ["contactable_id", "contactable_type"], name: "index_contacts_on_contactable_id_and_contactable_type", using: :btree

  create_table "data_migration_records", force: true do |t|
    t.string "version"
  end

  add_index "data_migration_records", ["version"], name: "index_data_migration_records_on_version", unique: true, using: :btree

  create_table "default_news_organisation_image_data", force: true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_collection_group_memberships", force: true do |t|
    t.integer  "document_id"
    t.integer  "document_collection_group_id"
    t.integer  "ordering"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "document_collection_group_memberships", ["document_collection_group_id", "ordering"], name: "index_dc_group_memberships_on_dc_group_id_and_ordering", using: :btree
  add_index "document_collection_group_memberships", ["document_id"], name: "index_document_collection_group_memberships_on_document_id", using: :btree

  create_table "document_collection_groups", force: true do |t|
    t.integer  "document_collection_id"
    t.string   "heading"
    t.text     "body"
    t.integer  "ordering"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "document_collection_groups", ["document_collection_id", "ordering"], name: "index_dc_groups_on_dc_id_and_ordering", using: :btree

  create_table "document_sources", force: true do |t|
    t.integer "document_id"
    t.string  "url",                        null: false
    t.integer "import_id"
    t.integer "row_number"
    t.string  "locale",      default: "en"
  end

  add_index "document_sources", ["document_id"], name: "index_document_sources_on_document_id", using: :btree
  add_index "document_sources", ["url"], name: "index_document_sources_on_url", unique: true, using: :btree

  create_table "documents", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "document_type"
    t.string   "content_id"
    t.integer  "government_id"
  end

  add_index "documents", ["document_type"], name: "index_documents_on_document_type", using: :btree
  add_index "documents", ["slug", "document_type"], name: "index_documents_on_slug_and_document_type", unique: true, using: :btree

  create_table "edition_authors", force: true do |t|
    t.integer  "edition_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_authors", ["edition_id"], name: "index_edition_authors_on_edition_id", using: :btree
  add_index "edition_authors", ["user_id"], name: "index_edition_authors_on_user_id", using: :btree

  create_table "edition_dependencies", force: true do |t|
    t.integer "edition_id"
    t.integer "dependable_id"
    t.string  "dependable_type"
  end

  add_index "edition_dependencies", ["dependable_id", "dependable_type", "edition_id"], name: "index_edition_dependencies_on_dependable_and_edition", unique: true, using: :btree

  create_table "edition_mainstream_categories", force: true do |t|
    t.integer  "edition_id"
    t.integer  "mainstream_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_mainstream_categories", ["edition_id"], name: "index_edition_mainstream_categories_on_edition_id", using: :btree
  add_index "edition_mainstream_categories", ["mainstream_category_id"], name: "index_edition_mainstream_categories_on_mainstream_category_id", using: :btree

  create_table "edition_ministerial_roles", force: true do |t|
    t.integer  "edition_id"
    t.integer  "ministerial_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_ministerial_roles", ["edition_id"], name: "index_edition_ministerial_roles_on_edition_id", using: :btree
  add_index "edition_ministerial_roles", ["ministerial_role_id"], name: "index_edition_ministerial_roles_on_ministerial_role_id", using: :btree

  create_table "edition_organisations", force: true do |t|
    t.integer  "edition_id"
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "lead",            default: false, null: false
    t.integer  "lead_ordering"
  end

  add_index "edition_organisations", ["edition_id", "organisation_id"], name: "index_edition_organisations_on_edition_id_and_organisation_id", unique: true, using: :btree
  add_index "edition_organisations", ["organisation_id"], name: "index_edition_organisations_on_organisation_id", using: :btree

  create_table "edition_policies", force: true do |t|
    t.integer  "edition_id"
    t.string   "policy_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_policies", ["edition_id"], name: "index_edition_policies_on_edition_id", using: :btree
  add_index "edition_policies", ["policy_content_id"], name: "index_edition_policies_on_policy_content_id", using: :btree

  create_table "edition_policy_groups", force: true do |t|
    t.integer "edition_id"
    t.integer "policy_group_id"
  end

  create_table "edition_relations", force: true do |t|
    t.integer  "edition_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "document_id"
  end

  add_index "edition_relations", ["document_id"], name: "index_edition_relations_on_document_id", using: :btree
  add_index "edition_relations", ["edition_id"], name: "index_edition_relations_on_edition_id", using: :btree

  create_table "edition_role_appointments", force: true do |t|
    t.integer "edition_id"
    t.integer "role_appointment_id"
  end

  add_index "edition_role_appointments", ["edition_id"], name: "index_edition_role_appointments_on_edition_id", using: :btree
  add_index "edition_role_appointments", ["role_appointment_id"], name: "index_edition_role_appointments_on_role_appointment_id", using: :btree

  create_table "edition_statistical_data_sets", force: true do |t|
    t.integer "edition_id"
    t.integer "document_id"
  end

  add_index "edition_statistical_data_sets", ["document_id"], name: "index_edition_statistical_data_sets_on_document_id", using: :btree
  add_index "edition_statistical_data_sets", ["edition_id"], name: "index_edition_statistical_data_sets_on_edition_id", using: :btree

  create_table "edition_translations", force: true do |t|
    t.integer  "edition_id"
    t.string   "locale"
    t.string   "title"
    t.text     "summary"
    t.text     "body",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_translations", ["edition_id"], name: "index_edition_translations_on_edition_id", using: :btree
  add_index "edition_translations", ["locale"], name: "index_edition_translations_on_locale", using: :btree

  create_table "edition_world_locations", force: true do |t|
    t.integer  "edition_id"
    t.integer  "world_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_world_locations", ["edition_id", "world_location_id"], name: "idx_edition_world_locations_on_edition_and_world_location_ids", unique: true, using: :btree
  add_index "edition_world_locations", ["edition_id"], name: "index_edition_world_locations_on_edition_id", using: :btree
  add_index "edition_world_locations", ["world_location_id"], name: "index_edition_world_locations_on_world_location_id", using: :btree

  create_table "edition_worldwide_organisations", force: true do |t|
    t.integer  "edition_id"
    t.integer  "worldwide_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_worldwide_organisations", ["edition_id"], name: "index_edition_worldwide_orgs_on_edition_id", using: :btree
  add_index "edition_worldwide_organisations", ["worldwide_organisation_id"], name: "index_edition_worldwide_orgs_on_worldwide_organisation_id", using: :btree

  create_table "editioned_supporting_page_mappings", force: true do |t|
    t.integer  "old_supporting_page_id"
    t.integer  "new_supporting_page_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "editioned_supporting_page_mappings", ["old_supporting_page_id"], name: "index_editioned_supporting_page_mappings", unique: true, using: :btree

  create_table "editions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                default: 0
    t.integer  "document_id"
    t.string   "state",                                       default: "draft", null: false
    t.string   "type"
    t.integer  "role_appointment_id"
    t.string   "location"
    t.datetime "delivered_on"
    t.datetime "major_change_published_at"
    t.datetime "first_published_at"
    t.integer  "speech_type_id"
    t.boolean  "stub",                                        default: false
    t.text     "change_note"
    t.boolean  "force_published"
    t.boolean  "minor_change",                                default: false
    t.integer  "publication_type_id"
    t.string   "related_mainstream_content_url"
    t.string   "related_mainstream_content_title"
    t.string   "additional_related_mainstream_content_url"
    t.string   "additional_related_mainstream_content_title"
    t.integer  "alternative_format_provider_id"
    t.datetime "public_timestamp"
    t.integer  "primary_mainstream_category_id"
    t.datetime "scheduled_publication"
    t.boolean  "replaces_businesslink",                       default: false
    t.boolean  "access_limited",                                                null: false
    t.integer  "published_major_version"
    t.integer  "published_minor_version"
    t.integer  "operational_field_id"
    t.text     "roll_call_introduction"
    t.integer  "news_article_type_id"
    t.boolean  "relevant_to_local_government",                default: false
    t.string   "person_override"
    t.boolean  "external",                                    default: false
    t.string   "external_url"
    t.datetime "opening_at"
    t.datetime "closing_at"
    t.integer  "corporate_information_page_type_id"
    t.string   "need_ids"
    t.string   "primary_locale",                              default: "en",    null: false
    t.boolean  "political",                                   default: false
  end

  add_index "editions", ["alternative_format_provider_id"], name: "index_editions_on_alternative_format_provider_id", using: :btree
  add_index "editions", ["closing_at"], name: "index_editions_on_closing_at", using: :btree
  add_index "editions", ["document_id"], name: "index_editions_on_document_id", using: :btree
  add_index "editions", ["first_published_at"], name: "index_editions_on_first_published_at", using: :btree
  add_index "editions", ["opening_at"], name: "index_editions_on_opening_at", using: :btree
  add_index "editions", ["operational_field_id"], name: "index_editions_on_operational_field_id", using: :btree
  add_index "editions", ["primary_mainstream_category_id"], name: "index_editions_on_primary_mainstream_category_id", using: :btree
  add_index "editions", ["public_timestamp", "document_id"], name: "index_editions_on_public_timestamp_and_document_id", using: :btree
  add_index "editions", ["public_timestamp"], name: "index_editions_on_public_timestamp", using: :btree
  add_index "editions", ["publication_type_id"], name: "index_editions_on_publication_type_id", using: :btree
  add_index "editions", ["role_appointment_id"], name: "index_editions_on_role_appointment_id", using: :btree
  add_index "editions", ["speech_type_id"], name: "index_editions_on_speech_type_id", using: :btree
  add_index "editions", ["state", "type"], name: "index_editions_on_state_and_type", using: :btree
  add_index "editions", ["state"], name: "index_editions_on_state", using: :btree
  add_index "editions", ["type"], name: "index_editions_on_type", using: :btree

  create_table "editorial_remarks", force: true do |t|
    t.text     "body"
    t.integer  "edition_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editorial_remarks", ["author_id"], name: "index_editorial_remarks_on_author_id", using: :btree
  add_index "editorial_remarks", ["edition_id"], name: "index_editorial_remarks_on_edition_id", using: :btree

  create_table "fact_check_requests", force: true do |t|
    t.integer  "edition_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address"
    t.text     "comments"
    t.text     "instructions"
    t.integer  "requestor_id"
  end

  add_index "fact_check_requests", ["edition_id"], name: "index_fact_check_requests_on_edition_id", using: :btree
  add_index "fact_check_requests", ["key"], name: "index_fact_check_requests_on_key", unique: true, using: :btree
  add_index "fact_check_requests", ["requestor_id"], name: "index_fact_check_requests_on_requestor_id", using: :btree

  create_table "fatality_notice_casualties", force: true do |t|
    t.integer "fatality_notice_id"
    t.text    "personal_details"
  end

  create_table "feature_flags", force: true do |t|
    t.string  "key"
    t.boolean "enabled", default: false
  end

  create_table "feature_lists", force: true do |t|
    t.integer  "featurable_id"
    t.string   "featurable_type"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_lists", ["featurable_id", "featurable_type", "locale"], name: "featurable_lists_unique_locale_per_featurable", unique: true, using: :btree

  create_table "featured_items", force: true do |t|
    t.integer  "item_id",                              null: false
    t.string   "item_type",                            null: false
    t.integer  "featured_topics_and_policies_list_id"
    t.integer  "ordering"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  add_index "featured_items", ["featured_topics_and_policies_list_id", "ordering"], name: "idx_featured_items_on_featured_ts_and_ps_list_id_and_ordering", using: :btree
  add_index "featured_items", ["featured_topics_and_policies_list_id"], name: "index_featured_items_on_featured_topics_and_policies_list_id", using: :btree
  add_index "featured_items", ["item_id", "item_type"], name: "index_featured_items_on_item_id_and_item_type", using: :btree

  create_table "featured_links", force: true do |t|
    t.string   "url"
    t.string   "title"
    t.integer  "linkable_id"
    t.string   "linkable_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "featured_topics_and_policies_lists", force: true do |t|
    t.integer  "organisation_id",                          null: false
    t.text     "summary"
    t.boolean  "link_to_filtered_policies", default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "featured_topics_and_policies_lists", ["organisation_id"], name: "index_featured_topics_and_policies_lists_on_organisation_id", using: :btree

  create_table "features", force: true do |t|
    t.integer  "document_id"
    t.integer  "feature_list_id"
    t.string   "carrierwave_image"
    t.string   "alt_text"
    t.integer  "ordering"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "topical_event_id"
    t.integer  "offsite_link_id"
  end

  add_index "features", ["document_id"], name: "index_features_on_document_id", using: :btree
  add_index "features", ["feature_list_id", "ordering"], name: "index_features_on_feature_list_id_and_ordering", unique: true, using: :btree
  add_index "features", ["feature_list_id"], name: "index_features_on_feature_list_id", using: :btree
  add_index "features", ["offsite_link_id"], name: "index_features_on_offsite_link_id", using: :btree
  add_index "features", ["ordering"], name: "index_features_on_ordering", using: :btree

  create_table "financial_reports", force: true do |t|
    t.integer "organisation_id"
    t.integer "funding",         limit: 8
    t.integer "spending",        limit: 8
    t.integer "year"
  end

  add_index "financial_reports", ["organisation_id", "year"], name: "index_financial_reports_on_organisation_id_and_year", unique: true, using: :btree
  add_index "financial_reports", ["organisation_id"], name: "index_financial_reports_on_organisation_id", using: :btree
  add_index "financial_reports", ["year"], name: "index_financial_reports_on_year", using: :btree

  create_table "force_publication_attempts", force: true do |t|
    t.integer  "import_id"
    t.integer  "total_documents"
    t.integer  "successful_documents"
    t.datetime "enqueued_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "log",                  limit: 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "force_publication_attempts", ["import_id"], name: "index_force_publication_attempts_on_import_id", using: :btree

  create_table "governments", force: true do |t|
    t.string   "slug"
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "governments", ["end_date"], name: "index_governments_on_end_date", using: :btree
  add_index "governments", ["name"], name: "index_governments_on_name", unique: true, using: :btree
  add_index "governments", ["slug"], name: "index_governments_on_slug", unique: true, using: :btree
  add_index "governments", ["start_date"], name: "index_governments_on_start_date", using: :btree

  create_table "govspeak_contents", force: true do |t|
    t.integer  "html_attachment_id"
    t.text     "body",                       limit: 16777215
    t.boolean  "manually_numbered_headings"
    t.text     "computed_body_html",         limit: 16777215
    t.text     "computed_headers_html"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "govspeak_contents", ["html_attachment_id"], name: "index_govspeak_contents_on_html_attachment_id", using: :btree

  create_table "group_memberships", force: true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id", using: :btree
  add_index "group_memberships", ["person_id"], name: "index_group_memberships_on_person_id", using: :btree

  create_table "groups", force: true do |t|
    t.integer  "organisation_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.text     "description"
  end

  add_index "groups", ["organisation_id"], name: "index_groups_on_organisation_id", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

  create_table "historical_account_roles", force: true do |t|
    t.integer  "role_id"
    t.integer  "historical_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "historical_account_roles", ["historical_account_id"], name: "index_historical_account_roles_on_historical_account_id", using: :btree
  add_index "historical_account_roles", ["role_id"], name: "index_historical_account_roles_on_role_id", using: :btree

  create_table "historical_accounts", force: true do |t|
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

  add_index "historical_accounts", ["person_id"], name: "index_historical_accounts_on_person_id", using: :btree

  create_table "home_page_list_items", force: true do |t|
    t.integer  "home_page_list_id", null: false
    t.integer  "item_id",           null: false
    t.string   "item_type",         null: false
    t.integer  "ordering"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_page_list_items", ["home_page_list_id", "ordering"], name: "index_home_page_list_items_on_home_page_list_id_and_ordering", using: :btree
  add_index "home_page_list_items", ["home_page_list_id"], name: "index_home_page_list_items_on_home_page_list_id", using: :btree
  add_index "home_page_list_items", ["item_id", "item_type"], name: "index_home_page_list_items_on_item_id_and_item_type", using: :btree

  create_table "home_page_lists", force: true do |t|
    t.integer  "owner_id",   null: false
    t.string   "owner_type", null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_page_lists", ["owner_id", "owner_type", "name"], name: "index_home_page_lists_on_owner_id_and_owner_type_and_name", unique: true, using: :btree

  create_table "image_data", force: true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: true do |t|
    t.integer  "image_data_id"
    t.integer  "edition_id"
    t.string   "alt_text"
    t.text     "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["edition_id"], name: "index_images_on_edition_id", using: :btree
  add_index "images", ["image_data_id"], name: "index_images_on_image_data_id", using: :btree

  create_table "import_errors", force: true do |t|
    t.integer  "import_id"
    t.integer  "row_number"
    t.text     "message"
    t.datetime "created_at"
  end

  add_index "import_errors", ["import_id"], name: "index_import_errors_on_import_id", using: :btree

  create_table "import_logs", force: true do |t|
    t.integer  "import_id"
    t.integer  "row_number"
    t.string   "level"
    t.text     "message"
    t.datetime "created_at"
  end

  create_table "imports", force: true do |t|
    t.string   "original_filename"
    t.string   "data_type"
    t.text     "csv_data",           limit: 2147483647
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

  create_table "links_reports", force: true do |t|
    t.text     "links",                limit: 16777215
    t.text     "broken_links"
    t.string   "status"
    t.string   "link_reportable_type"
    t.integer  "link_reportable_id"
    t.datetime "completed_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "links_reports", ["link_reportable_id", "link_reportable_type"], name: "link_reportable_index", using: :btree

  create_table "mainstream_categories", force: true do |t|
    t.string   "slug"
    t.string   "title"
    t.string   "parent_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent_tag"
    t.text     "description"
  end

  add_index "mainstream_categories", ["slug"], name: "index_mainstream_categories_on_slug", unique: true, using: :btree

  create_table "nation_inapplicabilities", force: true do |t|
    t.integer  "nation_id"
    t.integer  "edition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alternative_url"
  end

  add_index "nation_inapplicabilities", ["edition_id"], name: "index_nation_inapplicabilities_on_edition_id", using: :btree
  add_index "nation_inapplicabilities", ["nation_id"], name: "index_nation_inapplicabilities_on_nation_id", using: :btree

  create_table "offsite_links", force: true do |t|
    t.string   "title"
    t.string   "summary"
    t.string   "url"
    t.string   "link_type"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "operational_fields", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
  end

  add_index "operational_fields", ["slug"], name: "index_operational_fields_on_slug", using: :btree

  create_table "organisation_classifications", force: true do |t|
    t.integer  "organisation_id",                   null: false
    t.integer  "classification_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
    t.boolean  "lead",              default: false, null: false
    t.integer  "lead_ordering"
  end

  add_index "organisation_classifications", ["classification_id"], name: "index_org_classifications_on_classification_id", using: :btree
  add_index "organisation_classifications", ["organisation_id", "ordering"], name: "index_org_classifications_on_organisation_id_and_ordering", unique: true, using: :btree
  add_index "organisation_classifications", ["organisation_id"], name: "index_org_classifications_on_organisation_id", using: :btree

  create_table "organisation_mainstream_categories", force: true do |t|
    t.integer  "organisation_id",                     null: false
    t.integer  "mainstream_category_id",              null: false
    t.integer  "ordering",               default: 99, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisation_mainstream_categories", ["mainstream_category_id"], name: "index_org_mainstream_cats_on_mainstream_cat_id", using: :btree
  add_index "organisation_mainstream_categories", ["organisation_id", "mainstream_category_id"], name: "index_org_mainstream_cats_on_org_id_and_mainstream_cat_id", unique: true, using: :btree
  add_index "organisation_mainstream_categories", ["organisation_id"], name: "index_org_mainstream_cats_on_org_id", using: :btree

  create_table "organisation_roles", force: true do |t|
    t.integer  "organisation_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering"
  end

  add_index "organisation_roles", ["organisation_id"], name: "index_organisation_roles_on_organisation_id", using: :btree
  add_index "organisation_roles", ["role_id"], name: "index_organisation_roles_on_role_id", using: :btree

  create_table "organisation_supersedings", force: true do |t|
    t.integer "superseded_organisation_id"
    t.integer "superseding_organisation_id"
  end

  add_index "organisation_supersedings", ["superseded_organisation_id"], name: "index_organisation_supersedings_on_superseded_organisation_id", using: :btree

  create_table "organisation_translations", force: true do |t|
    t.integer  "organisation_id"
    t.string   "locale"
    t.string   "name"
    t.text     "logo_formatted_name"
    t.string   "acronym"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisation_translations", ["locale"], name: "index_organisation_translations_on_locale", using: :btree
  add_index "organisation_translations", ["name"], name: "index_organisation_translations_on_name", using: :btree
  add_index "organisation_translations", ["organisation_id"], name: "index_organisation_translations_on_organisation_id", using: :btree

  create_table "organisational_relationships", force: true do |t|
    t.integer  "parent_organisation_id"
    t.integer  "child_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisational_relationships", ["child_organisation_id"], name: "index_organisational_relationships_on_child_organisation_id", using: :btree
  add_index "organisational_relationships", ["parent_organisation_id"], name: "index_organisational_relationships_on_parent_organisation_id", using: :btree

  create_table "organisations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                                                     null: false
    t.string   "url"
    t.string   "alternative_format_contact_email"
    t.string   "govuk_status",                            default: "live", null: false
    t.integer  "organisation_logo_type_id",               default: 2
    t.string   "analytics_identifier"
    t.boolean  "handles_fatalities",                      default: false
    t.integer  "important_board_members",                 default: 1
    t.integer  "default_news_organisation_image_data_id"
    t.datetime "closed_at"
    t.integer  "organisation_brand_colour_id"
    t.boolean  "ocpa_regulated"
    t.boolean  "public_meetings"
    t.boolean  "public_minutes"
    t.boolean  "register_of_interests"
    t.boolean  "regulatory_function"
    t.string   "logo"
    t.string   "organisation_type_key"
    t.boolean  "foi_exempt",                              default: false,  null: false
    t.string   "organisation_chart_url"
    t.string   "govuk_closed_status"
    t.string   "custom_jobs_url"
    t.string   "content_id"
    t.string   "homepage_type",                           default: "news"
    t.boolean  "political",                               default: false
  end

  add_index "organisations", ["content_id"], name: "index_organisations_on_content_id", unique: true, using: :btree
  add_index "organisations", ["default_news_organisation_image_data_id"], name: "index_organisations_on_default_news_organisation_image_data_id", using: :btree
  add_index "organisations", ["organisation_logo_type_id"], name: "index_organisations_on_organisation_logo_type_id", using: :btree
  add_index "organisations", ["organisation_type_key"], name: "index_organisations_on_organisation_type_key", using: :btree
  add_index "organisations", ["slug"], name: "index_organisations_on_slug", unique: true, using: :btree

  create_table "people", force: true do |t|
    t.string   "title"
    t.string   "forename"
    t.string   "surname"
    t.string   "letters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "carrierwave_image"
    t.string   "slug"
    t.boolean  "privy_counsellor",  default: false
    t.string   "content_id"
  end

  add_index "people", ["slug"], name: "index_people_on_slug", unique: true, using: :btree

  create_table "person_translations", force: true do |t|
    t.integer  "person_id"
    t.string   "locale"
    t.text     "biography"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "person_translations", ["locale"], name: "index_person_translations_on_locale", using: :btree
  add_index "person_translations", ["person_id"], name: "index_person_translations_on_person_id", using: :btree

  create_table "policy_groups", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.text     "summary"
    t.string   "slug"
  end

  add_index "policy_groups", ["slug"], name: "index_policy_groups_on_slug", using: :btree

  create_table "promotional_feature_items", force: true do |t|
    t.integer  "promotional_feature_id"
    t.text     "summary"
    t.string   "image"
    t.string   "image_alt_text"
    t.string   "title"
    t.string   "title_url"
    t.boolean  "double_width",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_feature_items", ["promotional_feature_id"], name: "index_promotional_feature_items_on_promotional_feature_id", using: :btree

  create_table "promotional_feature_links", force: true do |t|
    t.integer  "promotional_feature_item_id"
    t.string   "url"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_feature_links", ["promotional_feature_item_id"], name: "index_promotional_feature_links_on_promotional_feature_item_id", using: :btree

  create_table "promotional_features", force: true do |t|
    t.integer  "organisation_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_features", ["organisation_id"], name: "index_promotional_features_on_organisation_id", using: :btree

  create_table "recent_edition_openings", force: true do |t|
    t.integer  "edition_id", null: false
    t.integer  "editor_id",  null: false
    t.datetime "created_at", null: false
  end

  add_index "recent_edition_openings", ["edition_id", "editor_id"], name: "index_recent_edition_openings_on_edition_id_and_editor_id", unique: true, using: :btree

  create_table "responses", force: true do |t|
    t.integer  "edition_id"
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "published_on"
    t.string   "type"
  end

  add_index "responses", ["edition_id", "type"], name: "index_responses_on_edition_id_and_type", using: :btree
  add_index "responses", ["edition_id"], name: "index_responses_on_edition_id", using: :btree

  create_table "role_appointments", force: true do |t|
    t.integer  "role_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  add_index "role_appointments", ["ended_at"], name: "index_role_appointments_on_ended_at", using: :btree
  add_index "role_appointments", ["person_id"], name: "index_role_appointments_on_person_id", using: :btree
  add_index "role_appointments", ["role_id"], name: "index_role_appointments_on_role_id", using: :btree

  create_table "role_translations", force: true do |t|
    t.integer  "role_id"
    t.string   "locale"
    t.string   "name"
    t.text     "responsibilities"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_translations", ["locale"], name: "index_role_translations_on_locale", using: :btree
  add_index "role_translations", ["name"], name: "index_role_translations_on_name", using: :btree
  add_index "role_translations", ["role_id"], name: "index_role_translations_on_role_id", using: :btree

  create_table "roles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                         null: false
    t.boolean  "permanent_secretary",          default: false
    t.boolean  "cabinet_member",               default: false, null: false
    t.string   "slug"
    t.boolean  "chief_of_the_defence_staff",   default: false, null: false
    t.integer  "whip_organisation_id"
    t.integer  "seniority",                    default: 100
    t.integer  "attends_cabinet_type_id"
    t.integer  "role_payment_type_id"
    t.boolean  "supports_historical_accounts", default: false, null: false
    t.integer  "whip_ordering",                default: 100
    t.string   "content_id"
  end

  add_index "roles", ["attends_cabinet_type_id"], name: "index_roles_on_attends_cabinet_type_id", using: :btree
  add_index "roles", ["slug"], name: "index_roles_on_slug", using: :btree
  add_index "roles", ["supports_historical_accounts"], name: "index_roles_on_supports_historical_accounts", using: :btree

  create_table "sitewide_settings", force: true do |t|
    t.string   "key"
    t.text     "description"
    t.boolean  "on"
    t.text     "govspeak"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "social_media_accounts", force: true do |t|
    t.integer  "socialable_id"
    t.integer  "social_media_service_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "socialable_type"
    t.string   "title"
  end

  add_index "social_media_accounts", ["social_media_service_id"], name: "index_social_media_accounts_on_social_media_service_id", using: :btree
  add_index "social_media_accounts", ["socialable_id"], name: "index_social_media_accounts_on_organisation_id", using: :btree

  create_table "social_media_services", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specialist_sectors", force: true do |t|
    t.integer  "edition_id"
    t.string   "tag"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "primary",    default: false
  end

  add_index "specialist_sectors", ["edition_id", "tag"], name: "index_specialist_sectors_on_edition_id_and_tag", unique: true, using: :btree

  create_table "sponsorships", force: true do |t|
    t.integer  "organisation_id"
    t.integer  "worldwide_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsorships", ["organisation_id", "worldwide_organisation_id"], name: "unique_sponsorships", unique: true, using: :btree
  add_index "sponsorships", ["worldwide_organisation_id"], name: "index_sponsorships_on_worldwide_organisation_id", using: :btree

  create_table "statistics_announcement_dates", force: true do |t|
    t.integer  "statistics_announcement_id"
    t.datetime "release_date"
    t.integer  "precision"
    t.boolean  "confirmed"
    t.string   "change_note"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "creator_id"
  end

  add_index "statistics_announcement_dates", ["creator_id"], name: "index_statistics_announcement_dates_on_creator_id", using: :btree
  add_index "statistics_announcement_dates", ["statistics_announcement_id", "created_at"], name: "statistics_announcement_release_date", using: :btree

  create_table "statistics_announcement_organisations", force: true do |t|
    t.integer  "statistics_announcement_id"
    t.integer  "organisation_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "statistics_announcement_organisations", ["organisation_id"], name: "index_statistics_announcement_organisations_on_organisation_id", using: :btree
  add_index "statistics_announcement_organisations", ["statistics_announcement_id", "organisation_id"], name: "index_on_statistics_announcement_id_and_organisation_id", using: :btree

  create_table "statistics_announcement_topics", force: true do |t|
    t.integer  "statistics_announcement_id"
    t.integer  "topic_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "statistics_announcement_topics", ["statistics_announcement_id"], name: "index_statistics_announcement_topics_on_statistics_announcement", using: :btree
  add_index "statistics_announcement_topics", ["topic_id"], name: "index_statistics_announcement_topics_on_topic_id", using: :btree

  create_table "statistics_announcements", force: true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "summary"
    t.integer  "publication_type_id"
    t.integer  "topic_id"
    t.integer  "creator_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "publication_id"
    t.text     "cancellation_reason"
    t.datetime "cancelled_at"
    t.integer  "cancelled_by_id"
  end

  add_index "statistics_announcements", ["cancelled_by_id"], name: "index_statistics_announcements_on_cancelled_by_id", using: :btree
  add_index "statistics_announcements", ["creator_id"], name: "index_statistics_announcements_on_creator_id", using: :btree
  add_index "statistics_announcements", ["publication_id"], name: "index_statistics_announcements_on_publication_id", using: :btree
  add_index "statistics_announcements", ["slug"], name: "index_statistics_announcements_on_slug", using: :btree
  add_index "statistics_announcements", ["title"], name: "index_statistics_announcements_on_title", using: :btree
  add_index "statistics_announcements", ["topic_id"], name: "index_statistics_announcements_on_topic_id", using: :btree

  create_table "supporting_page_redirects", force: true do |t|
    t.integer  "policy_document_id"
    t.integer  "supporting_page_document_id"
    t.string   "original_slug"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "supporting_page_redirects", ["policy_document_id", "original_slug"], name: "index_supporting_page_redirects_on_policy_and_slug", unique: true, using: :btree

  create_table "take_part_pages", force: true do |t|
    t.string   "title",                              null: false
    t.string   "slug",                               null: false
    t.string   "summary",                            null: false
    t.text     "body",              limit: 16777215, null: false
    t.string   "carrierwave_image"
    t.string   "image_alt_text"
    t.integer  "ordering",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "take_part_pages", ["ordering"], name: "index_take_part_pages_on_ordering", using: :btree
  add_index "take_part_pages", ["slug"], name: "index_take_part_pages_on_slug", unique: true, using: :btree

  create_table "unpublishings", force: true do |t|
    t.integer  "edition_id"
    t.integer  "unpublishing_reason_id"
    t.text     "explanation"
    t.text     "alternative_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
    t.string   "slug"
    t.boolean  "redirect",               default: false
  end

  add_index "unpublishings", ["edition_id"], name: "index_unpublishings_on_edition_id", using: :btree
  add_index "unpublishings", ["unpublishing_reason_id"], name: "index_unpublishings_on_unpublishing_reason_id", using: :btree

  create_table "user_world_locations", force: true do |t|
    t.integer "user_id"
    t.integer "world_location_id"
  end

  add_index "user_world_locations", ["user_id", "world_location_id"], name: "index_user_world_locations_on_user_id_and_world_location_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "uid"
    t.integer  "version"
    t.text     "permissions"
    t.boolean  "remotely_signed_out", default: false
    t.string   "organisation_slug"
    t.boolean  "disabled",            default: false
  end

  add_index "users", ["disabled"], name: "index_users_on_disabled", using: :btree
  add_index "users", ["organisation_slug"], name: "index_users_on_organisation_slug", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "state"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "world_location_translations", force: true do |t|
    t.integer  "world_location_id"
    t.string   "locale"
    t.string   "name"
    t.text     "mission_statement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  add_index "world_location_translations", ["locale"], name: "index_world_location_translations_on_locale", using: :btree
  add_index "world_location_translations", ["world_location_id"], name: "index_world_location_translations_on_world_location_id", using: :btree

  create_table "world_locations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.boolean  "active",                           default: false, null: false
    t.integer  "world_location_type_id",                           null: false
    t.string   "iso2",                   limit: 2
    t.string   "analytics_identifier"
    t.string   "content_id"
  end

  add_index "world_locations", ["iso2"], name: "index_world_locations_on_iso2", unique: true, using: :btree
  add_index "world_locations", ["slug"], name: "index_world_locations_on_slug", using: :btree
  add_index "world_locations", ["world_location_type_id"], name: "index_world_locations_on_world_location_type_id", using: :btree

  create_table "worldwide_office_worldwide_services", force: true do |t|
    t.integer  "worldwide_office_id",  null: false
    t.integer  "worldwide_service_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worldwide_offices", force: true do |t|
    t.integer  "worldwide_organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worldwide_office_type_id",  null: false
    t.string   "slug"
  end

  add_index "worldwide_offices", ["slug"], name: "index_worldwide_offices_on_slug", using: :btree
  add_index "worldwide_offices", ["worldwide_organisation_id"], name: "index_worldwide_offices_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisation_roles", force: true do |t|
    t.integer  "worldwide_organisation_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_roles", ["role_id"], name: "index_worldwide_org_roles_on_role_id", using: :btree
  add_index "worldwide_organisation_roles", ["worldwide_organisation_id"], name: "index_worldwide_org_roles_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisation_translations", force: true do |t|
    t.integer  "worldwide_organisation_id"
    t.string   "locale"
    t.string   "name"
    t.text     "services"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_translations", ["locale"], name: "index_worldwide_org_translations_on_locale", using: :btree
  add_index "worldwide_organisation_translations", ["worldwide_organisation_id"], name: "index_worldwide_org_translations_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisation_world_locations", force: true do |t|
    t.integer  "worldwide_organisation_id"
    t.integer  "world_location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_world_locations", ["world_location_id"], name: "index_worldwide_org_world_locations_on_world_location_id", using: :btree
  add_index "worldwide_organisation_world_locations", ["worldwide_organisation_id"], name: "index_worldwide_org_world_locations_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisations", force: true do |t|
    t.string   "url"
    t.string   "slug"
    t.string   "logo_formatted_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "main_office_id"
    t.integer  "default_news_organisation_image_data_id"
    t.string   "analytics_identifier"
    t.string   "content_id"
  end

  add_index "worldwide_organisations", ["default_news_organisation_image_data_id"], name: "index_worldwide_organisations_on_image_data_id", using: :btree
  add_index "worldwide_organisations", ["slug"], name: "index_worldwide_organisations_on_slug", unique: true, using: :btree

  create_table "worldwide_services", force: true do |t|
    t.string   "name",            null: false
    t.integer  "service_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
