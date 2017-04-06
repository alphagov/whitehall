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

ActiveRecord::Schema.define(version: 20170411161614) do

  create_table "about_pages", force: :cascade do |t|
    t.integer  "topical_event_id",    limit: 4
    t.string   "name",                limit: 255
    t.text     "summary",             limit: 65535
    t.text     "body",                limit: 65535
    t.string   "read_more_link_text", limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "content_id",          limit: 255
  end

  create_table "access_and_opening_times", force: :cascade do |t|
    t.text     "body",            limit: 65535
    t.string   "accessible_type", limit: 255
    t.integer  "accessible_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_and_opening_times", ["accessible_id", "accessible_type"], name: "accessible_index", using: :btree

  create_table "attachment_data", force: :cascade do |t|
    t.string   "carrierwave_file", limit: 255
    t.string   "content_type",     limit: 255
    t.integer  "file_size",        limit: 4
    t.integer  "number_of_pages",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "replaced_by_id",   limit: 4
  end

  add_index "attachment_data", ["replaced_by_id"], name: "index_attachment_data_on_replaced_by_id", using: :btree

  create_table "attachment_sources", force: :cascade do |t|
    t.integer "attachment_id", limit: 4
    t.string  "url",           limit: 255
  end

  add_index "attachment_sources", ["attachment_id"], name: "index_attachment_sources_on_attachment_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                           limit: 255
    t.boolean  "accessible"
    t.string   "isbn",                            limit: 255
    t.string   "unique_reference",                limit: 255
    t.string   "command_paper_number",            limit: 255
    t.string   "order_url",                       limit: 255
    t.integer  "price_in_pence",                  limit: 4
    t.integer  "attachment_data_id",              limit: 4
    t.integer  "ordering",                        limit: 4,                   null: false
    t.string   "hoc_paper_number",                limit: 255
    t.string   "parliamentary_session",           limit: 255
    t.boolean  "unnumbered_command_paper"
    t.boolean  "unnumbered_hoc_paper"
    t.integer  "attachable_id",                   limit: 4
    t.string   "attachable_type",                 limit: 255
    t.string   "type",                            limit: 255
    t.string   "slug",                            limit: 255
    t.string   "locale",                          limit: 255
    t.string   "external_url",                    limit: 255
    t.string   "content_id",                      limit: 255
    t.boolean  "deleted",                                     default: false, null: false
    t.string   "print_meta_data_contact_address", limit: 255
    t.string   "web_isbn",                        limit: 255
  end

  add_index "attachments", ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type", using: :btree
  add_index "attachments", ["attachable_type", "attachable_id", "ordering"], name: "no_duplicate_attachment_orderings", unique: true, using: :btree
  add_index "attachments", ["attachment_data_id"], name: "index_attachments_on_attachment_data_id", using: :btree
  add_index "attachments", ["ordering"], name: "index_attachments_on_ordering", using: :btree

  create_table "classification_featuring_image_data", force: :cascade do |t|
    t.string   "carrierwave_image", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classification_featurings", force: :cascade do |t|
    t.integer  "edition_id",                             limit: 4
    t.integer  "classification_id",                      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering",                               limit: 4
    t.integer  "classification_featuring_image_data_id", limit: 4
    t.string   "alt_text",                               limit: 255
    t.integer  "offsite_link_id",                        limit: 4
  end

  add_index "classification_featurings", ["classification_featuring_image_data_id"], name: "index_cl_feat_on_edition_org_image_data_id", using: :btree
  add_index "classification_featurings", ["classification_id"], name: "index_cl_feat_on_classification_id", using: :btree
  add_index "classification_featurings", ["edition_id", "classification_id"], name: "index_cl_feat_on_edition_id_and_classification_id", unique: true, using: :btree
  add_index "classification_featurings", ["offsite_link_id"], name: "index_classification_featurings_on_offsite_link_id", using: :btree

  create_table "classification_memberships", force: :cascade do |t|
    t.integer  "classification_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "edition_id",        limit: 4
    t.integer  "ordering",          limit: 4
  end

  add_index "classification_memberships", ["classification_id"], name: "index_classification_memberships_on_classification_id", using: :btree
  add_index "classification_memberships", ["edition_id"], name: "index_classification_memberships_on_edition_id", using: :btree

  create_table "classification_policies", force: :cascade do |t|
    t.integer  "classification_id", limit: 4
    t.string   "policy_content_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classification_policies", ["classification_id"], name: "index_classification_policies_on_classification_id", using: :btree
  add_index "classification_policies", ["policy_content_id"], name: "index_classification_policies_on_policy_content_id", using: :btree

  create_table "classification_relations", force: :cascade do |t|
    t.integer  "classification_id",         limit: 4, null: false
    t.integer  "related_classification_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classification_relations", ["classification_id"], name: "index_classification_relations_on_classification_id", using: :btree
  add_index "classification_relations", ["related_classification_id"], name: "index_classification_relations_on_related_classification_id", using: :btree

  create_table "classifications", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",       limit: 65535
    t.string   "slug",              limit: 255
    t.string   "state",             limit: 255
    t.string   "type",              limit: 255
    t.string   "carrierwave_image", limit: 255
    t.string   "logo_alt_text",     limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.string   "content_id",        limit: 255
  end

  add_index "classifications", ["slug"], name: "index_classifications_on_slug", using: :btree

  create_table "consultation_participations", force: :cascade do |t|
    t.integer  "edition_id",                    limit: 4
    t.string   "link_url",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                         limit: 255
    t.integer  "consultation_response_form_id", limit: 4
    t.text     "postal_address",                limit: 65535
  end

  add_index "consultation_participations", ["consultation_response_form_id"], name: "index_cons_participations_on_cons_response_form_id", using: :btree
  add_index "consultation_participations", ["edition_id"], name: "index_consultation_participations_on_edition_id", using: :btree

  create_table "consultation_response_form_data", force: :cascade do |t|
    t.string   "carrierwave_file", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consultation_response_forms", force: :cascade do |t|
    t.string   "title",                              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "consultation_response_form_data_id", limit: 4
  end

  create_table "contact_number_translations", force: :cascade do |t|
    t.integer  "contact_number_id", limit: 4
    t.string   "locale",            limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "label",             limit: 255
    t.string   "number",            limit: 255
  end

  add_index "contact_number_translations", ["contact_number_id"], name: "index_contact_number_translations_on_contact_number_id", using: :btree
  add_index "contact_number_translations", ["locale"], name: "index_contact_number_translations_on_locale", using: :btree

  create_table "contact_numbers", force: :cascade do |t|
    t.integer  "contact_id", limit: 4
    t.string   "label",      limit: 255
    t.string   "number",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_numbers", ["contact_id"], name: "index_contact_numbers_on_contact_id", using: :btree

  create_table "contact_translations", force: :cascade do |t|
    t.integer  "contact_id",       limit: 4
    t.string   "locale",           limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "title",            limit: 255
    t.text     "comments",         limit: 65535
    t.string   "recipient",        limit: 255
    t.text     "street_address",   limit: 65535
    t.string   "locality",         limit: 255
    t.string   "region",           limit: 255
    t.string   "email",            limit: 255
    t.string   "contact_form_url", limit: 255
  end

  add_index "contact_translations", ["contact_id"], name: "index_contact_translations_on_contact_id", using: :btree
  add_index "contact_translations", ["locale"], name: "index_contact_translations_on_locale", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.decimal "latitude",                     precision: 15, scale: 10
    t.decimal "longitude",                    precision: 15, scale: 10
    t.integer "contactable_id",   limit: 4
    t.string  "contactable_type", limit: 255
    t.string  "postal_code",      limit: 255
    t.integer "country_id",       limit: 4
    t.integer "contact_type_id",  limit: 4,                             null: false
    t.string  "content_id",       limit: 255,                           null: false
  end

  add_index "contacts", ["contact_type_id"], name: "index_contacts_on_contact_type_id", using: :btree
  add_index "contacts", ["contactable_id", "contactable_type"], name: "index_contacts_on_contactable_id_and_contactable_type", using: :btree

  create_table "data_migration_records", force: :cascade do |t|
    t.string "version", limit: 255
  end

  add_index "data_migration_records", ["version"], name: "index_data_migration_records_on_version", unique: true, using: :btree

  create_table "default_news_organisation_image_data", force: :cascade do |t|
    t.string   "carrierwave_image", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_collection_group_memberships", force: :cascade do |t|
    t.integer  "document_id",                  limit: 4
    t.integer  "document_collection_group_id", limit: 4
    t.integer  "ordering",                     limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "document_collection_group_memberships", ["document_collection_group_id", "ordering"], name: "index_dc_group_memberships_on_dc_group_id_and_ordering", using: :btree
  add_index "document_collection_group_memberships", ["document_id"], name: "index_document_collection_group_memberships_on_document_id", using: :btree

  create_table "document_collection_groups", force: :cascade do |t|
    t.integer  "document_collection_id", limit: 4
    t.string   "heading",                limit: 255
    t.text     "body",                   limit: 65535
    t.integer  "ordering",               limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "document_collection_groups", ["document_collection_id", "ordering"], name: "index_dc_groups_on_dc_id_and_ordering", using: :btree

  create_table "document_sources", force: :cascade do |t|
    t.integer "document_id", limit: 4
    t.string  "url",         limit: 255,                null: false
    t.integer "import_id",   limit: 4
    t.integer "row_number",  limit: 4
    t.string  "locale",      limit: 255, default: "en"
  end

  add_index "document_sources", ["document_id"], name: "index_document_sources_on_document_id", using: :btree
  add_index "document_sources", ["url"], name: "index_document_sources_on_url", unique: true, using: :btree

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",          limit: 255
    t.string   "document_type", limit: 255
    t.string   "content_id",    limit: 255, null: false
  end

  add_index "documents", ["document_type"], name: "index_documents_on_document_type", using: :btree
  add_index "documents", ["slug", "document_type"], name: "index_documents_on_slug_and_document_type", unique: true, using: :btree

  create_table "edition_authors", force: :cascade do |t|
    t.integer  "edition_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_authors", ["edition_id"], name: "index_edition_authors_on_edition_id", using: :btree
  add_index "edition_authors", ["user_id"], name: "index_edition_authors_on_user_id", using: :btree

  create_table "edition_dependencies", force: :cascade do |t|
    t.integer "edition_id",      limit: 4
    t.integer "dependable_id",   limit: 4
    t.string  "dependable_type", limit: 255
  end

  add_index "edition_dependencies", ["dependable_id", "dependable_type", "edition_id"], name: "index_edition_dependencies_on_dependable_and_edition", unique: true, using: :btree

  create_table "edition_organisations", force: :cascade do |t|
    t.integer  "edition_id",      limit: 4
    t.integer  "organisation_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "lead",                      default: false, null: false
    t.integer  "lead_ordering",   limit: 4
  end

  add_index "edition_organisations", ["edition_id", "organisation_id"], name: "index_edition_organisations_on_edition_id_and_organisation_id", unique: true, using: :btree
  add_index "edition_organisations", ["organisation_id"], name: "index_edition_organisations_on_organisation_id", using: :btree

  create_table "edition_policies", force: :cascade do |t|
    t.integer  "edition_id",        limit: 4
    t.string   "policy_content_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_policies", ["edition_id"], name: "index_edition_policies_on_edition_id", using: :btree
  add_index "edition_policies", ["policy_content_id"], name: "index_edition_policies_on_policy_content_id", using: :btree

  create_table "edition_relations", force: :cascade do |t|
    t.integer  "edition_id",  limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "document_id", limit: 4
  end

  add_index "edition_relations", ["document_id"], name: "index_edition_relations_on_document_id", using: :btree
  add_index "edition_relations", ["edition_id"], name: "index_edition_relations_on_edition_id", using: :btree

  create_table "edition_role_appointments", force: :cascade do |t|
    t.integer "edition_id",          limit: 4
    t.integer "role_appointment_id", limit: 4
  end

  add_index "edition_role_appointments", ["edition_id"], name: "index_edition_role_appointments_on_edition_id", using: :btree
  add_index "edition_role_appointments", ["role_appointment_id"], name: "index_edition_role_appointments_on_role_appointment_id", using: :btree

  create_table "edition_statistical_data_sets", force: :cascade do |t|
    t.integer "edition_id",  limit: 4
    t.integer "document_id", limit: 4
  end

  add_index "edition_statistical_data_sets", ["document_id"], name: "index_edition_statistical_data_sets_on_document_id", using: :btree
  add_index "edition_statistical_data_sets", ["edition_id"], name: "index_edition_statistical_data_sets_on_edition_id", using: :btree

  create_table "edition_translations", force: :cascade do |t|
    t.integer  "edition_id", limit: 4
    t.string   "locale",     limit: 255
    t.string   "title",      limit: 255
    t.text     "summary",    limit: 65535
    t.text     "body",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_translations", ["edition_id"], name: "index_edition_translations_on_edition_id", using: :btree
  add_index "edition_translations", ["locale"], name: "index_edition_translations_on_locale", using: :btree

  create_table "edition_world_locations", force: :cascade do |t|
    t.integer  "edition_id",        limit: 4
    t.integer  "world_location_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_world_locations", ["edition_id", "world_location_id"], name: "idx_edition_world_locations_on_edition_and_world_location_ids", unique: true, using: :btree
  add_index "edition_world_locations", ["edition_id"], name: "index_edition_world_locations_on_edition_id", using: :btree
  add_index "edition_world_locations", ["world_location_id"], name: "index_edition_world_locations_on_world_location_id", using: :btree

  create_table "edition_worldwide_organisations", force: :cascade do |t|
    t.integer  "edition_id",                limit: 4
    t.integer  "worldwide_organisation_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "edition_worldwide_organisations", ["edition_id"], name: "index_edition_worldwide_orgs_on_edition_id", using: :btree
  add_index "edition_worldwide_organisations", ["worldwide_organisation_id"], name: "index_edition_worldwide_orgs_on_worldwide_organisation_id", using: :btree

  create_table "editions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                                limit: 4,     default: 0
    t.integer  "document_id",                                 limit: 4
    t.string   "state",                                       limit: 255,   default: "draft", null: false
    t.string   "type",                                        limit: 255
    t.integer  "role_appointment_id",                         limit: 4
    t.string   "location",                                    limit: 255
    t.datetime "delivered_on"
    t.datetime "major_change_published_at"
    t.datetime "first_published_at"
    t.integer  "speech_type_id",                              limit: 4
    t.boolean  "stub",                                                      default: false
    t.text     "change_note",                                 limit: 65535
    t.boolean  "force_published"
    t.boolean  "minor_change",                                              default: false
    t.integer  "publication_type_id",                         limit: 4
    t.string   "related_mainstream_content_url",              limit: 255
    t.string   "related_mainstream_content_title",            limit: 255
    t.string   "additional_related_mainstream_content_url",   limit: 255
    t.string   "additional_related_mainstream_content_title", limit: 255
    t.integer  "alternative_format_provider_id",              limit: 4
    t.datetime "public_timestamp"
    t.datetime "scheduled_publication"
    t.boolean  "replaces_businesslink",                                     default: false
    t.boolean  "access_limited",                                                              null: false
    t.integer  "published_major_version",                     limit: 4
    t.integer  "published_minor_version",                     limit: 4
    t.integer  "operational_field_id",                        limit: 4
    t.text     "roll_call_introduction",                      limit: 65535
    t.integer  "news_article_type_id",                        limit: 4
    t.boolean  "relevant_to_local_government",                              default: false
    t.string   "person_override",                             limit: 255
    t.boolean  "external",                                                  default: false
    t.string   "external_url",                                limit: 255
    t.datetime "opening_at"
    t.datetime "closing_at"
    t.integer  "corporate_information_page_type_id",          limit: 4
    t.string   "need_ids",                                    limit: 255
    t.string   "primary_locale",                              limit: 255,   default: "en",    null: false
    t.boolean  "political",                                                 default: false
    t.string   "logo_url",                                    limit: 255
  end

  add_index "editions", ["alternative_format_provider_id"], name: "index_editions_on_alternative_format_provider_id", using: :btree
  add_index "editions", ["closing_at"], name: "index_editions_on_closing_at", using: :btree
  add_index "editions", ["document_id"], name: "index_editions_on_document_id", using: :btree
  add_index "editions", ["first_published_at"], name: "index_editions_on_first_published_at", using: :btree
  add_index "editions", ["opening_at"], name: "index_editions_on_opening_at", using: :btree
  add_index "editions", ["operational_field_id"], name: "index_editions_on_operational_field_id", using: :btree
  add_index "editions", ["public_timestamp", "document_id"], name: "index_editions_on_public_timestamp_and_document_id", using: :btree
  add_index "editions", ["public_timestamp"], name: "index_editions_on_public_timestamp", using: :btree
  add_index "editions", ["publication_type_id"], name: "index_editions_on_publication_type_id", using: :btree
  add_index "editions", ["role_appointment_id"], name: "index_editions_on_role_appointment_id", using: :btree
  add_index "editions", ["speech_type_id"], name: "index_editions_on_speech_type_id", using: :btree
  add_index "editions", ["state", "type"], name: "index_editions_on_state_and_type", using: :btree
  add_index "editions", ["state"], name: "index_editions_on_state", using: :btree
  add_index "editions", ["type"], name: "index_editions_on_type", using: :btree

  create_table "editorial_remarks", force: :cascade do |t|
    t.text     "body",       limit: 65535
    t.integer  "edition_id", limit: 4
    t.integer  "author_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "editorial_remarks", ["author_id"], name: "index_editorial_remarks_on_author_id", using: :btree
  add_index "editorial_remarks", ["edition_id"], name: "index_editorial_remarks_on_edition_id", using: :btree

  create_table "fact_check_requests", force: :cascade do |t|
    t.integer  "edition_id",    limit: 4
    t.string   "key",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address", limit: 255
    t.text     "comments",      limit: 65535
    t.text     "instructions",  limit: 65535
    t.integer  "requestor_id",  limit: 4
  end

  add_index "fact_check_requests", ["edition_id"], name: "index_fact_check_requests_on_edition_id", using: :btree
  add_index "fact_check_requests", ["key"], name: "index_fact_check_requests_on_key", unique: true, using: :btree
  add_index "fact_check_requests", ["requestor_id"], name: "index_fact_check_requests_on_requestor_id", using: :btree

  create_table "fatality_notice_casualties", force: :cascade do |t|
    t.integer "fatality_notice_id", limit: 4
    t.text    "personal_details",   limit: 65535
  end

  create_table "feature_flags", force: :cascade do |t|
    t.string  "key",     limit: 255
    t.boolean "enabled",             default: false
  end

  create_table "feature_lists", force: :cascade do |t|
    t.integer  "featurable_id",   limit: 4
    t.string   "featurable_type", limit: 255
    t.string   "locale",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_lists", ["featurable_id", "featurable_type", "locale"], name: "featurable_lists_unique_locale_per_featurable", unique: true, using: :btree

  create_table "featured_links", force: :cascade do |t|
    t.string   "url",           limit: 255
    t.string   "title",         limit: 255
    t.integer  "linkable_id",   limit: 4
    t.string   "linkable_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "featured_policies", force: :cascade do |t|
    t.string  "policy_content_id", limit: 255
    t.integer "ordering",          limit: 4,   null: false
    t.integer "organisation_id",   limit: 4
  end

  create_table "features", force: :cascade do |t|
    t.integer  "document_id",       limit: 4
    t.integer  "feature_list_id",   limit: 4
    t.string   "carrierwave_image", limit: 255
    t.string   "alt_text",          limit: 255
    t.integer  "ordering",          limit: 4
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "topical_event_id",  limit: 4
    t.integer  "offsite_link_id",   limit: 4
  end

  add_index "features", ["document_id"], name: "index_features_on_document_id", using: :btree
  add_index "features", ["feature_list_id", "ordering"], name: "index_features_on_feature_list_id_and_ordering", unique: true, using: :btree
  add_index "features", ["feature_list_id"], name: "index_features_on_feature_list_id", using: :btree
  add_index "features", ["offsite_link_id"], name: "index_features_on_offsite_link_id", using: :btree
  add_index "features", ["ordering"], name: "index_features_on_ordering", using: :btree

  create_table "financial_reports", force: :cascade do |t|
    t.integer "organisation_id", limit: 4
    t.integer "funding",         limit: 8
    t.integer "spending",        limit: 8
    t.integer "year",            limit: 4
  end

  add_index "financial_reports", ["organisation_id", "year"], name: "index_financial_reports_on_organisation_id_and_year", unique: true, using: :btree
  add_index "financial_reports", ["organisation_id"], name: "index_financial_reports_on_organisation_id", using: :btree
  add_index "financial_reports", ["year"], name: "index_financial_reports_on_year", using: :btree

  create_table "force_publication_attempts", force: :cascade do |t|
    t.integer  "import_id",            limit: 4
    t.integer  "total_documents",      limit: 4
    t.integer  "successful_documents", limit: 4
    t.datetime "enqueued_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "log",                  limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "force_publication_attempts", ["import_id"], name: "index_force_publication_attempts_on_import_id", using: :btree

  create_table "governments", force: :cascade do |t|
    t.string   "slug",       limit: 255
    t.string   "name",       limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "governments", ["end_date"], name: "index_governments_on_end_date", using: :btree
  add_index "governments", ["name"], name: "index_governments_on_name", unique: true, using: :btree
  add_index "governments", ["slug"], name: "index_governments_on_slug", unique: true, using: :btree
  add_index "governments", ["start_date"], name: "index_governments_on_start_date", using: :btree

  create_table "govspeak_contents", force: :cascade do |t|
    t.integer  "html_attachment_id",         limit: 4
    t.text     "body",                       limit: 16777215
    t.boolean  "manually_numbered_headings"
    t.text     "computed_body_html",         limit: 16777215
    t.text     "computed_headers_html",      limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "govspeak_contents", ["html_attachment_id"], name: "index_govspeak_contents_on_html_attachment_id", using: :btree

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "person_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id", using: :btree
  add_index "group_memberships", ["person_id"], name: "index_group_memberships_on_person_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "organisation_id", limit: 4
    t.string   "name",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",            limit: 255
    t.text     "description",     limit: 65535
  end

  add_index "groups", ["organisation_id"], name: "index_groups_on_organisation_id", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

  create_table "historical_account_roles", force: :cascade do |t|
    t.integer  "role_id",               limit: 4
    t.integer  "historical_account_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "historical_account_roles", ["historical_account_id"], name: "index_historical_account_roles_on_historical_account_id", using: :btree
  add_index "historical_account_roles", ["role_id"], name: "index_historical_account_roles_on_role_id", using: :btree

  create_table "historical_accounts", force: :cascade do |t|
    t.integer  "person_id",           limit: 4
    t.text     "summary",             limit: 65535
    t.text     "body",                limit: 65535
    t.string   "born",                limit: 255
    t.string   "died",                limit: 255
    t.text     "major_acts",          limit: 65535
    t.text     "interesting_facts",   limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "political_party_ids", limit: 255
  end

  add_index "historical_accounts", ["person_id"], name: "index_historical_accounts_on_person_id", using: :btree

  create_table "home_page_list_items", force: :cascade do |t|
    t.integer  "home_page_list_id", limit: 4,   null: false
    t.integer  "item_id",           limit: 4,   null: false
    t.string   "item_type",         limit: 255, null: false
    t.integer  "ordering",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_page_list_items", ["home_page_list_id", "ordering"], name: "index_home_page_list_items_on_home_page_list_id_and_ordering", using: :btree
  add_index "home_page_list_items", ["home_page_list_id"], name: "index_home_page_list_items_on_home_page_list_id", using: :btree
  add_index "home_page_list_items", ["item_id", "item_type"], name: "index_home_page_list_items_on_item_id_and_item_type", using: :btree

  create_table "home_page_lists", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4,   null: false
    t.string   "owner_type", limit: 255, null: false
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "home_page_lists", ["owner_id", "owner_type", "name"], name: "index_home_page_lists_on_owner_id_and_owner_type_and_name", unique: true, using: :btree

  create_table "image_data", force: :cascade do |t|
    t.string   "carrierwave_image", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: :cascade do |t|
    t.integer  "image_data_id", limit: 4
    t.integer  "edition_id",    limit: 4
    t.string   "alt_text",      limit: 255
    t.text     "caption",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["edition_id"], name: "index_images_on_edition_id", using: :btree
  add_index "images", ["image_data_id"], name: "index_images_on_image_data_id", using: :btree

  create_table "import_errors", force: :cascade do |t|
    t.integer  "import_id",  limit: 4
    t.integer  "row_number", limit: 4
    t.text     "message",    limit: 65535
    t.datetime "created_at"
  end

  add_index "import_errors", ["import_id"], name: "index_import_errors_on_import_id", using: :btree

  create_table "import_logs", force: :cascade do |t|
    t.integer  "import_id",  limit: 4
    t.integer  "row_number", limit: 4
    t.string   "level",      limit: 255
    t.text     "message",    limit: 65535
    t.datetime "created_at"
  end

  create_table "imports", force: :cascade do |t|
    t.string   "original_filename",  limit: 255
    t.string   "data_type",          limit: 255
    t.text     "csv_data",           limit: 4294967295
    t.text     "successful_rows",    limit: 65535
    t.integer  "creator_id",         limit: 4
    t.datetime "import_started_at"
    t.datetime "import_finished_at"
    t.integer  "total_rows",         limit: 4
    t.integer  "current_row",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "import_enqueued_at"
    t.integer  "organisation_id",    limit: 4
  end

  create_table "link_checker_api_report_links", force: :cascade do |t|
    t.integer  "link_checker_api_report_id", limit: 4
    t.string   "uri",                        limit: 255,   null: false
    t.string   "status",                     limit: 255,   null: false
    t.datetime "checked"
    t.text     "check_warnings",             limit: 65535
    t.text     "check_errors",               limit: 65535
    t.integer  "ordering",                   limit: 4,     null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "link_checker_api_report_links", ["link_checker_api_report_id"], name: "index_link_checker_api_report_id", using: :btree

  create_table "link_checker_api_reports", force: :cascade do |t|
    t.integer  "batch_id",             limit: 4,   null: false
    t.string   "status",               limit: 255, null: false
    t.string   "link_reportable_type", limit: 255
    t.integer  "link_reportable_id",   limit: 4
    t.datetime "completed_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "link_checker_api_reports", ["batch_id"], name: "index_link_checker_api_reports_on_batch_id", unique: true, using: :btree

  create_table "links_reports", force: :cascade do |t|
    t.text     "links",                limit: 16777215
    t.text     "broken_links",         limit: 65535
    t.string   "status",               limit: 255
    t.string   "link_reportable_type", limit: 255
    t.integer  "link_reportable_id",   limit: 4
    t.datetime "completed_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "links_reports", ["link_reportable_id", "link_reportable_type"], name: "link_reportable_index", using: :btree

  create_table "nation_inapplicabilities", force: :cascade do |t|
    t.integer  "nation_id",       limit: 4
    t.integer  "edition_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alternative_url", limit: 255
  end

  add_index "nation_inapplicabilities", ["edition_id"], name: "index_nation_inapplicabilities_on_edition_id", using: :btree
  add_index "nation_inapplicabilities", ["nation_id"], name: "index_nation_inapplicabilities_on_nation_id", using: :btree

  create_table "offsite_links", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "summary",     limit: 255
    t.string   "url",         limit: 255
    t.string   "link_type",   limit: 255
    t.integer  "parent_id",   limit: 4
    t.string   "parent_type", limit: 255
    t.datetime "date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "operational_fields", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description", limit: 65535
    t.string   "slug",        limit: 255
    t.string   "content_id",  limit: 255
  end

  add_index "operational_fields", ["slug"], name: "index_operational_fields_on_slug", using: :btree

  create_table "organisation_classifications", force: :cascade do |t|
    t.integer  "organisation_id",   limit: 4,                 null: false
    t.integer  "classification_id", limit: 4,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering",          limit: 4
    t.boolean  "lead",                        default: false, null: false
    t.integer  "lead_ordering",     limit: 4
  end

  add_index "organisation_classifications", ["classification_id"], name: "index_org_classifications_on_classification_id", using: :btree
  add_index "organisation_classifications", ["organisation_id", "ordering"], name: "index_org_classifications_on_organisation_id_and_ordering", unique: true, using: :btree
  add_index "organisation_classifications", ["organisation_id"], name: "index_org_classifications_on_organisation_id", using: :btree

  create_table "organisation_roles", force: :cascade do |t|
    t.integer  "organisation_id", limit: 4
    t.integer  "role_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ordering",        limit: 4
  end

  add_index "organisation_roles", ["organisation_id"], name: "index_organisation_roles_on_organisation_id", using: :btree
  add_index "organisation_roles", ["role_id"], name: "index_organisation_roles_on_role_id", using: :btree

  create_table "organisation_supersedings", force: :cascade do |t|
    t.integer "superseded_organisation_id",  limit: 4
    t.integer "superseding_organisation_id", limit: 4
  end

  add_index "organisation_supersedings", ["superseded_organisation_id"], name: "index_organisation_supersedings_on_superseded_organisation_id", using: :btree

  create_table "organisation_translations", force: :cascade do |t|
    t.integer  "organisation_id",     limit: 4
    t.string   "locale",              limit: 255
    t.string   "name",                limit: 255
    t.text     "logo_formatted_name", limit: 65535
    t.string   "acronym",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisation_translations", ["locale"], name: "index_organisation_translations_on_locale", using: :btree
  add_index "organisation_translations", ["name"], name: "index_organisation_translations_on_name", using: :btree
  add_index "organisation_translations", ["organisation_id"], name: "index_organisation_translations_on_organisation_id", using: :btree

  create_table "organisational_relationships", force: :cascade do |t|
    t.integer  "parent_organisation_id", limit: 4
    t.integer  "child_organisation_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisational_relationships", ["child_organisation_id"], name: "index_organisational_relationships_on_child_organisation_id", using: :btree
  add_index "organisational_relationships", ["parent_organisation_id"], name: "index_organisational_relationships_on_parent_organisation_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                                    limit: 255,                  null: false
    t.string   "url",                                     limit: 255
    t.string   "alternative_format_contact_email",        limit: 255
    t.string   "govuk_status",                            limit: 255, default: "live", null: false
    t.integer  "organisation_logo_type_id",               limit: 4,   default: 2
    t.string   "analytics_identifier",                    limit: 255
    t.boolean  "handles_fatalities",                                  default: false
    t.integer  "important_board_members",                 limit: 4,   default: 1
    t.integer  "default_news_organisation_image_data_id", limit: 4
    t.datetime "closed_at"
    t.integer  "organisation_brand_colour_id",            limit: 4
    t.boolean  "ocpa_regulated"
    t.boolean  "public_meetings"
    t.boolean  "public_minutes"
    t.boolean  "register_of_interests"
    t.boolean  "regulatory_function"
    t.string   "logo",                                    limit: 255
    t.string   "organisation_type_key",                   limit: 255
    t.boolean  "foi_exempt",                                          default: false,  null: false
    t.string   "organisation_chart_url",                  limit: 255
    t.string   "govuk_closed_status",                     limit: 255
    t.string   "custom_jobs_url",                         limit: 255
    t.string   "content_id",                              limit: 255
    t.string   "homepage_type",                           limit: 255, default: "news"
    t.boolean  "political",                                           default: false
    t.integer  "ministerial_ordering",                    limit: 4
  end

  add_index "organisations", ["content_id"], name: "index_organisations_on_content_id", unique: true, using: :btree
  add_index "organisations", ["default_news_organisation_image_data_id"], name: "index_organisations_on_default_news_organisation_image_data_id", using: :btree
  add_index "organisations", ["organisation_logo_type_id"], name: "index_organisations_on_organisation_logo_type_id", using: :btree
  add_index "organisations", ["organisation_type_key"], name: "index_organisations_on_organisation_type_key", using: :btree
  add_index "organisations", ["slug"], name: "index_organisations_on_slug", unique: true, using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.string   "forename",          limit: 255
    t.string   "surname",           limit: 255
    t.string   "letters",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "carrierwave_image", limit: 255
    t.string   "slug",              limit: 255
    t.boolean  "privy_counsellor",              default: false
    t.string   "content_id",        limit: 255
  end

  add_index "people", ["slug"], name: "index_people_on_slug", unique: true, using: :btree

  create_table "person_translations", force: :cascade do |t|
    t.integer  "person_id",  limit: 4
    t.string   "locale",     limit: 255
    t.text     "biography",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "person_translations", ["locale"], name: "index_person_translations_on_locale", using: :btree
  add_index "person_translations", ["person_id"], name: "index_person_translations_on_person_id", using: :btree

  create_table "policy_groups", force: :cascade do |t|
    t.string   "email",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.text     "summary",     limit: 65535
    t.string   "slug",        limit: 255
    t.string   "content_id",  limit: 255,   null: false
  end

  add_index "policy_groups", ["slug"], name: "index_policy_groups_on_slug", using: :btree

  create_table "promotional_feature_items", force: :cascade do |t|
    t.integer  "promotional_feature_id", limit: 4
    t.text     "summary",                limit: 65535
    t.string   "image",                  limit: 255
    t.string   "image_alt_text",         limit: 255
    t.string   "title",                  limit: 255
    t.string   "title_url",              limit: 255
    t.boolean  "double_width",                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_feature_items", ["promotional_feature_id"], name: "index_promotional_feature_items_on_promotional_feature_id", using: :btree

  create_table "promotional_feature_links", force: :cascade do |t|
    t.integer  "promotional_feature_item_id", limit: 4
    t.string   "url",                         limit: 255
    t.string   "text",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_feature_links", ["promotional_feature_item_id"], name: "index_promotional_feature_links_on_promotional_feature_item_id", using: :btree

  create_table "promotional_features", force: :cascade do |t|
    t.integer  "organisation_id", limit: 4
    t.string   "title",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotional_features", ["organisation_id"], name: "index_promotional_features_on_organisation_id", using: :btree

  create_table "recent_edition_openings", force: :cascade do |t|
    t.integer  "edition_id", limit: 4, null: false
    t.integer  "editor_id",  limit: 4, null: false
    t.datetime "created_at",           null: false
  end

  add_index "recent_edition_openings", ["edition_id", "editor_id"], name: "index_recent_edition_openings_on_edition_id_and_editor_id", unique: true, using: :btree

  create_table "related_mainstreams", force: :cascade do |t|
    t.integer  "edition_id", limit: 4
    t.string   "content_id", limit: 255
    t.boolean  "additional",             default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "related_mainstreams", ["edition_id"], name: "index_related_mainstreams_on_edition_id", using: :btree

  create_table "responses", force: :cascade do |t|
    t.integer  "edition_id",   limit: 4
    t.text     "summary",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "published_on"
    t.string   "type",         limit: 255
  end

  add_index "responses", ["edition_id", "type"], name: "index_responses_on_edition_id_and_type", using: :btree
  add_index "responses", ["edition_id"], name: "index_responses_on_edition_id", using: :btree

  create_table "role_appointments", force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "person_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  add_index "role_appointments", ["ended_at"], name: "index_role_appointments_on_ended_at", using: :btree
  add_index "role_appointments", ["person_id"], name: "index_role_appointments_on_person_id", using: :btree
  add_index "role_appointments", ["role_id"], name: "index_role_appointments_on_role_id", using: :btree

  create_table "role_translations", force: :cascade do |t|
    t.integer  "role_id",          limit: 4
    t.string   "locale",           limit: 255
    t.string   "name",             limit: 255
    t.text     "responsibilities", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_translations", ["locale"], name: "index_role_translations_on_locale", using: :btree
  add_index "role_translations", ["name"], name: "index_role_translations_on_name", using: :btree
  add_index "role_translations", ["role_id"], name: "index_role_translations_on_role_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                         limit: 255,                 null: false
    t.boolean  "permanent_secretary",                      default: false
    t.boolean  "cabinet_member",                           default: false, null: false
    t.string   "slug",                         limit: 255
    t.boolean  "chief_of_the_defence_staff",               default: false, null: false
    t.integer  "whip_organisation_id",         limit: 4
    t.integer  "seniority",                    limit: 4,   default: 100
    t.integer  "attends_cabinet_type_id",      limit: 4
    t.integer  "role_payment_type_id",         limit: 4
    t.boolean  "supports_historical_accounts",             default: false, null: false
    t.integer  "whip_ordering",                limit: 4,   default: 100
    t.string   "content_id",                   limit: 255
  end

  add_index "roles", ["attends_cabinet_type_id"], name: "index_roles_on_attends_cabinet_type_id", using: :btree
  add_index "roles", ["slug"], name: "index_roles_on_slug", using: :btree
  add_index "roles", ["supports_historical_accounts"], name: "index_roles_on_supports_historical_accounts", using: :btree

  create_table "sitewide_settings", force: :cascade do |t|
    t.string   "key",         limit: 255
    t.text     "description", limit: 65535
    t.boolean  "on"
    t.text     "govspeak",    limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "social_media_accounts", force: :cascade do |t|
    t.integer  "socialable_id",           limit: 4
    t.integer  "social_media_service_id", limit: 4
    t.string   "url",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "socialable_type",         limit: 255
    t.string   "title",                   limit: 255
  end

  add_index "social_media_accounts", ["social_media_service_id"], name: "index_social_media_accounts_on_social_media_service_id", using: :btree
  add_index "social_media_accounts", ["socialable_id"], name: "index_social_media_accounts_on_organisation_id", using: :btree

  create_table "social_media_services", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specialist_sectors", force: :cascade do |t|
    t.integer  "edition_id",       limit: 4,                   null: false
    t.string   "tag",              limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "primary",                      default: false
    t.string   "topic_content_id", limit: 255
  end

  add_index "specialist_sectors", ["edition_id", "tag"], name: "index_specialist_sectors_on_edition_id_and_tag", unique: true, using: :btree

  create_table "sponsorships", force: :cascade do |t|
    t.integer  "organisation_id",           limit: 4
    t.integer  "worldwide_organisation_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsorships", ["organisation_id", "worldwide_organisation_id"], name: "unique_sponsorships", unique: true, using: :btree
  add_index "sponsorships", ["worldwide_organisation_id"], name: "index_sponsorships_on_worldwide_organisation_id", using: :btree

  create_table "statistics_announcement_dates", force: :cascade do |t|
    t.integer  "statistics_announcement_id", limit: 4
    t.datetime "release_date"
    t.integer  "precision",                  limit: 4
    t.boolean  "confirmed"
    t.text     "change_note",                limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "creator_id",                 limit: 4
  end

  add_index "statistics_announcement_dates", ["creator_id"], name: "index_statistics_announcement_dates_on_creator_id", using: :btree
  add_index "statistics_announcement_dates", ["statistics_announcement_id", "created_at"], name: "statistics_announcement_release_date", using: :btree

  create_table "statistics_announcement_organisations", force: :cascade do |t|
    t.integer  "statistics_announcement_id", limit: 4
    t.integer  "organisation_id",            limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "statistics_announcement_organisations", ["organisation_id"], name: "index_statistics_announcement_organisations_on_organisation_id", using: :btree
  add_index "statistics_announcement_organisations", ["statistics_announcement_id", "organisation_id"], name: "index_on_statistics_announcement_id_and_organisation_id", using: :btree

  create_table "statistics_announcement_topics", force: :cascade do |t|
    t.integer  "statistics_announcement_id", limit: 4
    t.integer  "topic_id",                   limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "statistics_announcement_topics", ["statistics_announcement_id"], name: "index_statistics_announcement_topics_on_statistics_announcement", using: :btree
  add_index "statistics_announcement_topics", ["topic_id"], name: "index_statistics_announcement_topics_on_topic_id", using: :btree

  create_table "statistics_announcements", force: :cascade do |t|
    t.string   "title",               limit: 255
    t.string   "slug",                limit: 255
    t.text     "summary",             limit: 65535
    t.integer  "publication_type_id", limit: 4
    t.integer  "topic_id",            limit: 4
    t.integer  "creator_id",          limit: 4
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "publication_id",      limit: 4
    t.text     "cancellation_reason", limit: 65535
    t.datetime "cancelled_at"
    t.integer  "cancelled_by_id",     limit: 4
    t.string   "publishing_state",    limit: 255,   default: "published", null: false
    t.string   "redirect_url",        limit: 255
    t.string   "content_id",          limit: 255,                         null: false
  end

  add_index "statistics_announcements", ["cancelled_by_id"], name: "index_statistics_announcements_on_cancelled_by_id", using: :btree
  add_index "statistics_announcements", ["creator_id"], name: "index_statistics_announcements_on_creator_id", using: :btree
  add_index "statistics_announcements", ["publication_id"], name: "index_statistics_announcements_on_publication_id", using: :btree
  add_index "statistics_announcements", ["slug"], name: "index_statistics_announcements_on_slug", using: :btree
  add_index "statistics_announcements", ["title"], name: "index_statistics_announcements_on_title", using: :btree
  add_index "statistics_announcements", ["topic_id"], name: "index_statistics_announcements_on_topic_id", using: :btree

  create_table "sync_check_results", force: :cascade do |t|
    t.string   "check_class", limit: 255
    t.integer  "item_id",     limit: 4
    t.text     "failures",    limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "sync_check_results", ["check_class", "item_id"], name: "index_sync_check_results_on_check_class_and_item_id", unique: true, using: :btree

  create_table "take_part_pages", force: :cascade do |t|
    t.string   "title",             limit: 255,      null: false
    t.string   "slug",              limit: 255,      null: false
    t.string   "summary",           limit: 255,      null: false
    t.text     "body",              limit: 16777215, null: false
    t.string   "carrierwave_image", limit: 255
    t.string   "image_alt_text",    limit: 255
    t.integer  "ordering",          limit: 4,        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_id",        limit: 255
  end

  add_index "take_part_pages", ["ordering"], name: "index_take_part_pages_on_ordering", using: :btree
  add_index "take_part_pages", ["slug"], name: "index_take_part_pages_on_slug", unique: true, using: :btree

  create_table "unpublishings", force: :cascade do |t|
    t.integer  "edition_id",             limit: 4
    t.integer  "unpublishing_reason_id", limit: 4
    t.text     "explanation",            limit: 65535
    t.text     "alternative_url",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type",          limit: 255
    t.string   "slug",                   limit: 255
    t.boolean  "redirect",                             default: false
    t.string   "content_id",             limit: 255,                   null: false
  end

  add_index "unpublishings", ["edition_id"], name: "index_unpublishings_on_edition_id", using: :btree
  add_index "unpublishings", ["unpublishing_reason_id"], name: "index_unpublishings_on_unpublishing_reason_id", using: :btree

  create_table "user_world_locations", force: :cascade do |t|
    t.integer "user_id",           limit: 4
    t.integer "world_location_id", limit: 4
  end

  add_index "user_world_locations", ["user_id", "world_location_id"], name: "index_user_world_locations_on_user_id_and_world_location_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",               limit: 255
    t.string   "uid",                 limit: 255
    t.integer  "version",             limit: 4
    t.text     "permissions",         limit: 65535
    t.boolean  "remotely_signed_out",               default: false
    t.string   "organisation_slug",   limit: 255
    t.boolean  "disabled",                          default: false
  end

  add_index "users", ["disabled"], name: "index_users_on_disabled", using: :btree
  add_index "users", ["organisation_slug"], name: "index_users_on_organisation_slug", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
    t.text     "state",      limit: 65535
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "world_location_translations", force: :cascade do |t|
    t.integer  "world_location_id", limit: 4
    t.string   "locale",            limit: 255
    t.string   "name",              limit: 255
    t.text     "mission_statement", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",             limit: 255
  end

  add_index "world_location_translations", ["locale"], name: "index_world_location_translations_on_locale", using: :btree
  add_index "world_location_translations", ["world_location_id"], name: "index_world_location_translations_on_world_location_id", using: :btree

  create_table "world_locations", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                   limit: 255
    t.boolean  "active",                             default: false, null: false
    t.integer  "world_location_type_id", limit: 4,                   null: false
    t.string   "iso2",                   limit: 2
    t.string   "analytics_identifier",   limit: 255
    t.string   "content_id",             limit: 255
  end

  add_index "world_locations", ["iso2"], name: "index_world_locations_on_iso2", unique: true, using: :btree
  add_index "world_locations", ["slug"], name: "index_world_locations_on_slug", using: :btree
  add_index "world_locations", ["world_location_type_id"], name: "index_world_locations_on_world_location_type_id", using: :btree

  create_table "worldwide_office_worldwide_services", force: :cascade do |t|
    t.integer  "worldwide_office_id",  limit: 4, null: false
    t.integer  "worldwide_service_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worldwide_offices", force: :cascade do |t|
    t.integer  "worldwide_organisation_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worldwide_office_type_id",  limit: 4,   null: false
    t.string   "slug",                      limit: 255
  end

  add_index "worldwide_offices", ["slug"], name: "index_worldwide_offices_on_slug", using: :btree
  add_index "worldwide_offices", ["worldwide_organisation_id"], name: "index_worldwide_offices_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisation_roles", force: :cascade do |t|
    t.integer  "worldwide_organisation_id", limit: 4
    t.integer  "role_id",                   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_roles", ["role_id"], name: "index_worldwide_org_roles_on_role_id", using: :btree
  add_index "worldwide_organisation_roles", ["worldwide_organisation_id"], name: "index_worldwide_org_roles_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisation_translations", force: :cascade do |t|
    t.integer  "worldwide_organisation_id", limit: 4
    t.string   "locale",                    limit: 255
    t.string   "name",                      limit: 255
    t.text     "services",                  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_translations", ["locale"], name: "index_worldwide_org_translations_on_locale", using: :btree
  add_index "worldwide_organisation_translations", ["worldwide_organisation_id"], name: "index_worldwide_org_translations_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisation_world_locations", force: :cascade do |t|
    t.integer  "worldwide_organisation_id", limit: 4
    t.integer  "world_location_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "worldwide_organisation_world_locations", ["world_location_id"], name: "index_worldwide_org_world_locations_on_world_location_id", using: :btree
  add_index "worldwide_organisation_world_locations", ["worldwide_organisation_id"], name: "index_worldwide_org_world_locations_on_worldwide_organisation_id", using: :btree

  create_table "worldwide_organisations", force: :cascade do |t|
    t.string   "url",                                     limit: 255
    t.string   "slug",                                    limit: 255
    t.string   "logo_formatted_name",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "main_office_id",                          limit: 4
    t.integer  "default_news_organisation_image_data_id", limit: 4
    t.string   "analytics_identifier",                    limit: 255
    t.string   "content_id",                              limit: 255
  end

  add_index "worldwide_organisations", ["default_news_organisation_image_data_id"], name: "index_worldwide_organisations_on_image_data_id", using: :btree
  add_index "worldwide_organisations", ["slug"], name: "index_worldwide_organisations_on_slug", unique: true, using: :btree

  create_table "worldwide_services", force: :cascade do |t|
    t.string   "name",            limit: 255, null: false
    t.integer  "service_type_id", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "link_checker_api_report_links", "link_checker_api_reports"
  add_foreign_key "related_mainstreams", "editions"
end
