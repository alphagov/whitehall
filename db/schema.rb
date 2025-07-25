# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_08_124941) do
  create_table "assets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "asset_manager_id", null: false
    t.string "variant", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "assetable_type"
    t.bigint "assetable_id"
    t.string "filename"
    t.index ["asset_manager_id"], name: "index_assets_on_asset_manager_id"
    t.index ["assetable_type", "assetable_id"], name: "index_assets_on_assetable"
  end

  create_table "attachment_data", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "carrierwave_file"
    t.string "content_type"
    t.integer "file_size"
    t.integer "number_of_pages"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "replaced_by_id"
    t.index ["replaced_by_id"], name: "index_attachment_data_on_replaced_by_id"
  end

  create_table "attachment_sources", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "attachment_id"
    t.string "url"
    t.index ["attachment_id"], name: "index_attachment_sources_on_attachment_id"
  end

  create_table "attachments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "title"
    t.boolean "accessible"
    t.string "isbn"
    t.string "unique_reference"
    t.string "command_paper_number"
    t.integer "attachment_data_id"
    t.integer "ordering", null: false
    t.string "hoc_paper_number"
    t.string "parliamentary_session"
    t.boolean "unnumbered_command_paper"
    t.boolean "unnumbered_hoc_paper"
    t.integer "attachable_id"
    t.string "attachable_type"
    t.string "type"
    t.string "slug"
    t.string "locale"
    t.string "external_url"
    t.string "content_id"
    t.boolean "deleted", default: false, null: false
    t.boolean "safely_resluggable", default: true
    t.boolean "visual_editor"
    t.index ["attachable_id", "attachable_type"], name: "index_attachments_on_attachable_id_and_attachable_type"
    t.index ["attachable_type", "attachable_id", "ordering"], name: "no_duplicate_attachment_orderings", unique: true
    t.index ["attachment_data_id"], name: "index_attachments_on_attachment_data_id"
    t.index ["content_id"], name: "index_attachments_on_content_id"
    t.index ["ordering"], name: "index_attachments_on_ordering"
  end

  create_table "call_for_evidence_participations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.string "link_url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "email"
    t.integer "call_for_evidence_response_form_id"
    t.text "postal_address", size: :medium
    t.index ["call_for_evidence_response_form_id"], name: "index_cfes_participations_on_cfes_response_form_id"
    t.index ["edition_id"], name: "index_call_for_evidence_participations_on_edition_id"
  end

  create_table "call_for_evidence_response_form_data", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "carrierwave_file"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "call_for_evidence_response_forms", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "call_for_evidence_response_form_data_id"
  end

  create_table "call_for_evidence_responses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.text "summary"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "published_on"
    t.string "type"
    t.index ["edition_id", "type"], name: "index_call_for_evidence_responses_on_edition_id_and_type"
    t.index ["edition_id"], name: "index_call_for_evidence_responses_on_edition_id"
  end

  create_table "consultation_participations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.string "link_url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "email"
    t.integer "consultation_response_form_id"
    t.text "postal_address", size: :medium
    t.index ["consultation_response_form_id"], name: "index_cons_participations_on_cons_response_form_id"
    t.index ["edition_id"], name: "index_consultation_participations_on_edition_id"
  end

  create_table "consultation_response_form_data", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "carrierwave_file"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "consultation_response_forms", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "consultation_response_form_data_id"
  end

  create_table "consultation_responses", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.text "summary", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "published_on"
    t.string "type"
    t.index ["edition_id", "type"], name: "index_consultation_responses_on_edition_id_and_type"
    t.index ["edition_id"], name: "index_consultation_responses_on_edition_id"
  end

  create_table "contact_number_translations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "contact_number_id"
    t.string "locale"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "label"
    t.string "number"
    t.index ["contact_number_id"], name: "index_contact_number_translations_on_contact_number_id"
    t.index ["locale"], name: "index_contact_number_translations_on_locale"
  end

  create_table "contact_numbers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "contact_id"
    t.string "label"
    t.string "number"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["contact_id"], name: "index_contact_numbers_on_contact_id"
  end

  create_table "contact_translations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "contact_id"
    t.string "locale"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title"
    t.text "comments", size: :medium
    t.string "recipient"
    t.text "street_address", size: :medium
    t.string "locality"
    t.string "region"
    t.string "email"
    t.string "contact_form_url"
    t.index ["contact_id"], name: "index_contact_translations_on_contact_id"
    t.index ["locale"], name: "index_contact_translations_on_locale"
  end

  create_table "contacts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "contactable_id"
    t.string "contactable_type"
    t.string "postal_code"
    t.integer "country_id"
    t.integer "contact_type_id", null: false
    t.string "content_id", null: false
    t.index ["contact_type_id"], name: "index_contacts_on_contact_type_id"
    t.index ["contactable_id", "contactable_type"], name: "index_contacts_on_contactable_id_and_contactable_type"
  end

  create_table "content_block_documents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "content_id"
    t.string "sluggable_string"
    t.string "block_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "latest_edition_id"
    t.integer "live_edition_id"
    t.string "content_id_alias"
    t.datetime "deleted_at"
    t.index ["content_id_alias"], name: "index_content_block_documents_on_content_id_alias", unique: true
    t.index ["latest_edition_id"], name: "index_content_block_documents_on_latest_edition_id"
    t.index ["live_edition_id"], name: "index_content_block_documents_on_live_edition_id"
  end

  create_table "content_block_edition_authors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "edition_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["edition_id"], name: "index_content_block_edition_authors_on_edition_id"
    t.index ["user_id"], name: "index_content_block_edition_authors_on_user_id"
  end

  create_table "content_block_edition_organisations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "content_block_edition_id", null: false
    t.integer "organisation_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["content_block_edition_id"], name: "idx_on_content_block_edition_id_e433bc9b13"
    t.index ["organisation_id"], name: "index_content_block_edition_organisations_on_organisation_id"
  end

  create_table "content_block_editions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.json "details", null: false
    t.bigint "document_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "state", default: "draft", null: false
    t.datetime "scheduled_publication", precision: nil
    t.text "instructions_to_publishers"
    t.string "title", default: "", null: false
    t.text "internal_change_note"
    t.text "change_note"
    t.boolean "major_change"
    t.virtual "details_for_indexing", type: :text, as: "json_unquote(`details`)", stored: true
    t.index ["document_id"], name: "index_content_block_editions_on_document_id"
    t.index ["title", "details_for_indexing", "instructions_to_publishers"], name: "title_details_instructions_to_publishers", type: :fulltext
  end

  create_table "content_block_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "event", null: false
    t.string "whodunnit"
    t.datetime "created_at", precision: nil, null: false
    t.text "state"
    t.json "field_diffs"
    t.string "updated_embedded_object_type"
    t.string "updated_embedded_object_title"
    t.index ["item_id"], name: "index_content_block_versions_on_item_id"
    t.index ["item_type"], name: "index_content_block_versions_on_item_type"
  end

  create_table "data_migration_records", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "version"
    t.index ["version"], name: "index_data_migration_records_on_version", unique: true
  end

  create_table "document_collection_group_memberships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "document_id"
    t.integer "document_collection_group_id"
    t.integer "ordering"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "non_whitehall_link_id"
    t.index ["document_collection_group_id", "ordering"], name: "index_dc_group_memberships_on_dc_group_id_and_ordering"
    t.index ["document_id"], name: "index_document_collection_group_memberships_on_document_id"
    t.index ["non_whitehall_link_id"], name: "index_document_collection_non_whitehall_link"
  end

  create_table "document_collection_groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "document_collection_id"
    t.string "heading"
    t.text "body", size: :medium
    t.integer "ordering"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["document_collection_id", "ordering"], name: "index_dc_groups_on_dc_id_and_ordering"
  end

  create_table "document_collection_non_whitehall_links", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "content_id", null: false
    t.string "title", null: false
    t.text "base_path", size: :medium, null: false
    t.string "publishing_app", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "documents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug"
    t.string "document_type"
    t.string "content_id", null: false
    t.integer "latest_edition_id"
    t.integer "live_edition_id"
    t.index ["content_id"], name: "index_documents_on_content_id"
    t.index ["document_type"], name: "index_documents_on_document_type"
    t.index ["latest_edition_id"], name: "index_documents_on_latest_edition_id"
    t.index ["live_edition_id"], name: "index_documents_on_live_edition_id"
    t.index ["slug", "document_type"], name: "index_documents_on_slug_and_document_type", unique: true
  end

  create_table "edition_authors", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["edition_id"], name: "index_edition_authors_on_edition_id"
    t.index ["user_id"], name: "index_edition_authors_on_user_id"
  end

  create_table "edition_dependencies", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "dependable_id"
    t.string "dependable_type"
    t.index ["dependable_id", "dependable_type", "edition_id"], name: "index_edition_dependencies_on_dependable_and_edition", unique: true
  end

  create_table "edition_lead_images", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "image_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id"], name: "index_lead_image_on_edition_id", unique: true
  end

  create_table "edition_organisations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "organisation_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "lead", default: false, null: false
    t.integer "lead_ordering"
    t.index ["edition_id", "organisation_id"], name: "index_edition_organisations_on_edition_id_and_organisation_id", unique: true
    t.index ["organisation_id"], name: "index_edition_organisations_on_organisation_id"
  end

  create_table "edition_relations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "document_id"
    t.index ["document_id"], name: "index_edition_relations_on_document_id"
    t.index ["edition_id"], name: "index_edition_relations_on_edition_id"
  end

  create_table "edition_role_appointments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "role_appointment_id"
    t.index ["edition_id"], name: "index_edition_role_appointments_on_edition_id"
    t.index ["role_appointment_id"], name: "index_edition_role_appointments_on_role_appointment_id"
  end

  create_table "edition_roles", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "edition_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "edition_statistical_data_sets", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "document_id"
    t.index ["document_id"], name: "index_edition_statistical_data_sets_on_document_id"
    t.index ["edition_id"], name: "index_edition_statistical_data_sets_on_edition_id"
  end

  create_table "edition_translations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.string "locale"
    t.string "title"
    t.text "summary", size: :medium
    t.text "body", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.json "flexible_page_content"
    t.index ["edition_id"], name: "index_edition_translations_on_edition_id"
    t.index ["locale"], name: "index_edition_translations_on_locale"
  end

  create_table "edition_world_locations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "world_location_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["edition_id", "world_location_id"], name: "idx_edition_world_locations_on_edition_and_world_location_ids", unique: true
    t.index ["edition_id"], name: "index_edition_world_locations_on_edition_id"
    t.index ["world_location_id"], name: "index_edition_world_locations_on_world_location_id"
  end

  create_table "edition_worldwide_organisations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_edition_worldwide_organisations_on_document_id"
    t.index ["edition_id"], name: "index_edition_worldwide_organisations_on_edition_id"
  end

  create_table "editions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0
    t.integer "document_id"
    t.string "state", default: "draft", null: false
    t.string "type"
    t.integer "role_appointment_id"
    t.string "location"
    t.datetime "delivered_on", precision: nil
    t.datetime "major_change_published_at", precision: nil
    t.datetime "first_published_at", precision: nil
    t.integer "speech_type_id"
    t.boolean "stub", default: false
    t.text "change_note", size: :medium
    t.boolean "force_published"
    t.boolean "minor_change", default: false
    t.integer "publication_type_id"
    t.string "related_mainstream_content_url"
    t.string "related_mainstream_content_title"
    t.string "additional_related_mainstream_content_url"
    t.string "additional_related_mainstream_content_title"
    t.integer "alternative_format_provider_id"
    t.datetime "public_timestamp", precision: nil
    t.datetime "scheduled_publication", precision: nil
    t.boolean "replaces_businesslink", default: false
    t.boolean "access_limited", null: false
    t.integer "published_major_version"
    t.integer "published_minor_version"
    t.integer "operational_field_id"
    t.text "roll_call_introduction", size: :medium
    t.integer "news_article_type_id"
    t.string "person_override"
    t.boolean "external", default: false
    t.string "external_url"
    t.datetime "opening_at", precision: nil
    t.datetime "closing_at", precision: nil
    t.integer "corporate_information_page_type_id"
    t.string "primary_locale", default: "en", null: false
    t.boolean "political", default: false
    t.string "logo_url"
    t.boolean "read_consultation_principles", default: false
    t.boolean "all_nation_applicability", default: true
    t.string "image_display_option"
    t.string "auth_bypass_id", null: false
    t.string "taxonomy_topic_email_override"
    t.string "logo_formatted_name"
    t.string "analytics_identifier"
    t.integer "main_office_id"
    t.boolean "visual_editor"
    t.integer "government_id"
    t.string "flexible_page_type"
    t.datetime "revalidated_at"
    t.index ["alternative_format_provider_id"], name: "index_editions_on_alternative_format_provider_id"
    t.index ["closing_at"], name: "index_editions_on_closing_at"
    t.index ["document_id"], name: "index_editions_on_document_id"
    t.index ["first_published_at"], name: "index_editions_on_first_published_at"
    t.index ["flexible_page_type"], name: "index_editions_on_flexible_page_type"
    t.index ["government_id"], name: "fk_rails_6875303236"
    t.index ["main_office_id"], name: "index_editions_on_main_office_id"
    t.index ["opening_at"], name: "index_editions_on_opening_at"
    t.index ["operational_field_id"], name: "index_editions_on_operational_field_id"
    t.index ["public_timestamp", "document_id"], name: "index_editions_on_public_timestamp_and_document_id"
    t.index ["public_timestamp"], name: "index_editions_on_public_timestamp"
    t.index ["publication_type_id"], name: "index_editions_on_publication_type_id"
    t.index ["role_appointment_id"], name: "index_editions_on_role_appointment_id"
    t.index ["speech_type_id"], name: "index_editions_on_speech_type_id"
    t.index ["state", "type"], name: "index_editions_on_state_and_type"
    t.index ["state"], name: "index_editions_on_state"
    t.index ["type"], name: "index_editions_on_type"
    t.index ["updated_at"], name: "index_editions_on_updated_at"
  end

  create_table "editorial_remarks", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "body", size: :medium
    t.integer "edition_id"
    t.integer "author_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["author_id"], name: "index_editorial_remarks_on_author_id"
    t.index ["edition_id"], name: "index_editorial_remarks_on_edition_id"
  end

  create_table "fact_check_requests", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.string "key"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "email_address"
    t.text "comments", size: :medium
    t.text "instructions", size: :medium
    t.integer "requestor_id"
    t.index ["edition_id"], name: "index_fact_check_requests_on_edition_id"
    t.index ["key"], name: "index_fact_check_requests_on_key", unique: true
    t.index ["requestor_id"], name: "index_fact_check_requests_on_requestor_id"
  end

  create_table "fatality_notice_casualties", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "fatality_notice_id"
    t.text "personal_details", size: :medium
  end

  create_table "feature_lists", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "featurable_id"
    t.string "featurable_type"
    t.string "locale"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["featurable_id", "featurable_type", "locale"], name: "featurable_lists_unique_locale_per_featurable", unique: true
  end

  create_table "featured_image_data", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "carrierwave_image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "featured_imageable_type"
    t.integer "featured_imageable_id"
  end

  create_table "featured_link_translations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "url", size: :medium
    t.text "title", size: :medium
    t.string "locale", null: false
    t.integer "featured_link_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["featured_link_id"], name: "index_on_featured_link"
    t.index ["locale"], name: "index_on_locale"
  end

  create_table "featured_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "linkable_id"
    t.string "linkable_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "features", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "document_id"
    t.integer "feature_list_id"
    t.string "alt_text"
    t.integer "ordering"
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.integer "topical_event_id"
    t.integer "offsite_link_id"
    t.index ["document_id"], name: "index_features_on_document_id"
    t.index ["feature_list_id", "ordering"], name: "index_features_on_feature_list_id_and_ordering", unique: true
    t.index ["feature_list_id"], name: "index_features_on_feature_list_id"
    t.index ["offsite_link_id"], name: "index_features_on_offsite_link_id"
    t.index ["ordering"], name: "index_features_on_ordering"
  end

  create_table "flipflop_features", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "force_publication_attempts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "import_id"
    t.integer "total_documents"
    t.integer "successful_documents"
    t.datetime "enqueued_at", precision: nil
    t.datetime "started_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.text "log", size: :long
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["import_id"], name: "index_force_publication_attempts_on_import_id"
  end

  create_table "governments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "content_id", null: false
    t.index ["content_id"], name: "index_governments_on_content_id", unique: true
    t.index ["end_date"], name: "index_governments_on_end_date"
    t.index ["name"], name: "index_governments_on_name", unique: true
    t.index ["slug"], name: "index_governments_on_slug", unique: true
    t.index ["start_date"], name: "index_governments_on_start_date"
  end

  create_table "govspeak_contents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "html_attachment_id"
    t.text "body", size: :long
    t.boolean "manually_numbered_headings"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["html_attachment_id"], name: "index_govspeak_contents_on_html_attachment_id"
  end

  create_table "group_memberships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "group_id"
    t.integer "person_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["person_id"], name: "index_group_memberships_on_person_id"
  end

  create_table "groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "organisation_id"
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug"
    t.text "description", size: :medium
    t.index ["organisation_id"], name: "index_groups_on_organisation_id"
    t.index ["slug"], name: "index_groups_on_slug"
  end

  create_table "historical_account_roles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "role_id"
    t.integer "historical_account_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["historical_account_id"], name: "index_historical_account_roles_on_historical_account_id"
    t.index ["role_id"], name: "index_historical_account_roles_on_role_id"
  end

  create_table "historical_accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "person_id"
    t.text "summary", size: :medium
    t.text "body", size: :medium
    t.string "born"
    t.string "died"
    t.text "major_acts", size: :medium
    t.text "interesting_facts", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "political_party_ids"
    t.string "content_id"
    t.index ["person_id"], name: "index_historical_accounts_on_person_id"
  end

  create_table "home_page_list_items", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "home_page_list_id", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.integer "ordering"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["home_page_list_id", "ordering"], name: "index_home_page_list_items_on_home_page_list_id_and_ordering"
    t.index ["home_page_list_id"], name: "index_home_page_list_items_on_home_page_list_id"
    t.index ["item_id", "item_type"], name: "index_home_page_list_items_on_item_id_and_item_type"
  end

  create_table "home_page_lists", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "owner_id", null: false
    t.string "owner_type", null: false
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["owner_id", "owner_type", "name"], name: "index_home_page_lists_on_owner_id_and_owner_type_and_name", unique: true
  end

  create_table "image_data", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "carrierwave_image"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "image_kind", default: "default", null: false
  end

  create_table "images", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "image_data_id"
    t.integer "edition_id"
    t.string "alt_text"
    t.text "caption", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["edition_id"], name: "index_images_on_edition_id"
    t.index ["image_data_id"], name: "index_images_on_image_data_id"
  end

  create_table "link_checker_api_report_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "link_checker_api_report_id"
    t.text "uri", size: :medium, null: false
    t.string "status", null: false
    t.datetime "checked", precision: nil
    t.text "check_warnings", size: :medium
    t.text "check_errors", size: :medium
    t.integer "ordering", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "problem_summary", size: :medium
    t.text "suggested_fix", size: :medium
    t.text "check_dangers", size: :medium
    t.index ["link_checker_api_report_id"], name: "index_link_checker_api_report_id"
  end

  create_table "link_checker_api_reports", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "batch_id"
    t.string "status", null: false
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "edition_id"
    t.index ["batch_id"], name: "index_link_checker_api_reports_on_batch_id", unique: true
    t.index ["edition_id"], name: "index_link_checker_api_reports_on_edition_id", unique: true
  end

  create_table "nation_inapplicabilities", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "nation_id"
    t.integer "edition_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "alternative_url"
    t.index ["edition_id"], name: "index_nation_inapplicabilities_on_edition_id"
    t.index ["nation_id"], name: "index_nation_inapplicabilities_on_nation_id"
  end

  create_table "offsite_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "summary"
    t.string "url"
    t.string "link_type"
    t.integer "parent_id"
    t.string "parent_type"
    t.datetime "date", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "operational_fields", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "description", size: :medium
    t.string "slug"
    t.string "content_id"
    t.index ["slug"], name: "index_operational_fields_on_slug"
  end

  create_table "organisation_roles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "organisation_id"
    t.integer "role_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "ordering"
    t.index ["organisation_id"], name: "index_organisation_roles_on_organisation_id"
    t.index ["role_id"], name: "index_organisation_roles_on_role_id"
  end

  create_table "organisation_supersedings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "superseded_organisation_id"
    t.integer "superseding_organisation_id"
    t.index ["superseded_organisation_id"], name: "index_organisation_supersedings_on_superseded_organisation_id"
  end

  create_table "organisation_translations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "organisation_id"
    t.string "locale"
    t.string "name"
    t.text "logo_formatted_name", size: :medium
    t.string "acronym"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["locale"], name: "index_organisation_translations_on_locale"
    t.index ["name"], name: "index_organisation_translations_on_name"
    t.index ["organisation_id"], name: "index_organisation_translations_on_organisation_id"
  end

  create_table "organisational_relationships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "parent_organisation_id"
    t.integer "child_organisation_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["child_organisation_id"], name: "index_organisational_relationships_on_child_organisation_id"
    t.index ["parent_organisation_id"], name: "index_organisational_relationships_on_parent_organisation_id"
  end

  create_table "organisations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug", null: false
    t.string "url"
    t.string "alternative_format_contact_email"
    t.string "govuk_status", default: "live", null: false
    t.integer "organisation_logo_type_id", default: 2
    t.string "analytics_identifier"
    t.boolean "handles_fatalities", default: false
    t.datetime "closed_at", precision: nil
    t.integer "organisation_brand_colour_id"
    t.boolean "ocpa_regulated"
    t.boolean "public_meetings"
    t.boolean "public_minutes"
    t.boolean "register_of_interests"
    t.boolean "regulatory_function"
    t.string "logo"
    t.string "organisation_type_key"
    t.boolean "foi_exempt", default: false, null: false
    t.string "organisation_chart_url"
    t.string "govuk_closed_status"
    t.text "custom_jobs_url", size: :medium
    t.string "content_id"
    t.string "homepage_type", default: "news"
    t.boolean "political", default: false
    t.integer "ministerial_ordering"
    t.index ["content_id"], name: "index_organisations_on_content_id", unique: true
    t.index ["organisation_logo_type_id"], name: "index_organisations_on_organisation_logo_type_id"
    t.index ["organisation_type_key"], name: "index_organisations_on_organisation_type_key"
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
  end

  create_table "people", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "forename"
    t.string "surname"
    t.string "letters"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug"
    t.boolean "privy_counsellor", default: false
    t.string "content_id"
    t.index ["slug"], name: "index_people_on_slug", unique: true
  end

  create_table "person_translations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "person_id"
    t.string "locale"
    t.text "biography", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["locale"], name: "index_person_translations_on_locale"
    t.index ["person_id"], name: "index_person_translations_on_person_id"
  end

  create_table "policy_group_dependencies", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "policy_group_id"
    t.string "dependable_type"
    t.bigint "dependable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dependable_id", "dependable_type", "policy_group_id"], name: "index_policy_group_dependencies_on_dependable_and_policy_group", unique: true
    t.index ["dependable_type", "dependable_id"], name: "index_policy_group_dependencies_on_dependable"
    t.index ["policy_group_id"], name: "index_policy_group_dependencies_on_policy_group_id"
  end

  create_table "policy_groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name"
    t.text "description", size: :medium
    t.text "summary", size: :medium
    t.string "slug"
    t.string "content_id", null: false
    t.index ["slug"], name: "index_policy_groups_on_slug"
  end

  create_table "promotional_feature_items", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "promotional_feature_id"
    t.text "summary", size: :medium
    t.string "image"
    t.string "image_alt_text"
    t.string "title"
    t.string "title_url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "youtube_video_url"
    t.string "youtube_video_alt_text"
    t.index ["promotional_feature_id"], name: "index_promotional_feature_items_on_promotional_feature_id"
  end

  create_table "promotional_feature_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "promotional_feature_item_id"
    t.string "url"
    t.string "text"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["promotional_feature_item_id"], name: "index_promotional_feature_links_on_promotional_feature_item_id"
  end

  create_table "promotional_features", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "organisation_id"
    t.string "title"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "ordering"
    t.index ["organisation_id"], name: "index_promotional_features_on_organisation_id"
  end

  create_table "recent_edition_openings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id", null: false
    t.integer "editor_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["edition_id", "editor_id"], name: "index_recent_edition_openings_on_edition_id_and_editor_id", unique: true
  end

  create_table "related_mainstreams", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.string "content_id"
    t.boolean "additional", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["edition_id"], name: "index_related_mainstreams_on_edition_id"
  end

  create_table "republishing_events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "action", null: false
    t.text "reason", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_id"
    t.boolean "bulk", null: false
    t.integer "bulk_content_type"
    t.string "content_type"
    t.string "organisation_id"
    t.json "content_ids"
    t.index ["user_id"], name: "index_republishing_events_on_user_id"
  end

  create_table "review_reminders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "document_id"
    t.integer "creator_id"
    t.string "email_address"
    t.date "review_at"
    t.datetime "reminder_sent_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["creator_id"], name: "index_review_reminders_on_creator_id"
    t.index ["document_id"], name: "index_review_reminders_on_document_id"
    t.index ["review_at", "reminder_sent_at"], name: "index_review_reminders_on_review_at_and_reminder_sent_at"
  end

  create_table "role_appointments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "role_id"
    t.integer "person_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.string "content_id"
    t.integer "ordering"
    t.index ["ended_at"], name: "index_role_appointments_on_ended_at"
    t.index ["person_id"], name: "index_role_appointments_on_person_id"
    t.index ["role_id"], name: "index_role_appointments_on_role_id"
  end

  create_table "role_translations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "role_id"
    t.string "locale"
    t.string "name"
    t.text "responsibilities", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["locale"], name: "index_role_translations_on_locale"
    t.index ["name"], name: "index_role_translations_on_name"
    t.index ["role_id"], name: "index_role_translations_on_role_id"
  end

  create_table "roles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "type", null: false
    t.boolean "permanent_secretary", default: false
    t.boolean "cabinet_member", default: false, null: false
    t.string "slug"
    t.boolean "chief_of_the_defence_staff", default: false, null: false
    t.integer "whip_organisation_id"
    t.integer "seniority", default: 100
    t.integer "attends_cabinet_type_id"
    t.integer "role_payment_type_id"
    t.boolean "supports_historical_accounts", default: false, null: false
    t.integer "whip_ordering", default: 100
    t.string "content_id"
    t.index ["attends_cabinet_type_id"], name: "index_roles_on_attends_cabinet_type_id"
    t.index ["slug"], name: "index_roles_on_slug"
    t.index ["supports_historical_accounts"], name: "index_roles_on_supports_historical_accounts"
  end

  create_table "sitewide_settings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.text "description", size: :medium
    t.boolean "on"
    t.text "govspeak", size: :medium
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "social_media_account_translations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "url", size: :medium
    t.text "title", size: :medium
    t.string "locale", null: false
    t.integer "social_media_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locale"], name: "index_on_locale"
    t.index ["social_media_account_id"], name: "index_on_social_media_account"
  end

  create_table "social_media_accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "socialable_id"
    t.integer "social_media_service_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "socialable_type"
    t.integer "ordering"
    t.index ["social_media_service_id"], name: "index_social_media_accounts_on_social_media_service_id"
    t.index ["socialable_id"], name: "index_social_media_accounts_on_organisation_id"
  end

  create_table "social_media_services", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "statistics_announcement_dates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "statistics_announcement_id"
    t.datetime "release_date", precision: nil
    t.integer "precision"
    t.boolean "confirmed"
    t.text "change_note", size: :medium
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "creator_id"
    t.index ["creator_id"], name: "index_statistics_announcement_dates_on_creator_id"
    t.index ["statistics_announcement_id", "created_at"], name: "statistics_announcement_release_date"
  end

  create_table "statistics_announcement_organisations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "statistics_announcement_id"
    t.integer "organisation_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["organisation_id"], name: "index_statistics_announcement_organisations_on_organisation_id"
    t.index ["statistics_announcement_id", "organisation_id"], name: "index_on_statistics_announcement_id_and_organisation_id"
  end

  create_table "statistics_announcement_topics", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "statistics_announcement_id"
    t.integer "topic_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["statistics_announcement_id"], name: "index_statistics_announcement_topics_on_statistics_announcement"
    t.index ["topic_id"], name: "index_statistics_announcement_topics_on_topic_id"
  end

  create_table "statistics_announcements", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "summary", size: :medium
    t.integer "publication_type_id"
    t.integer "topic_id"
    t.integer "creator_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "publication_id"
    t.text "cancellation_reason", size: :medium
    t.datetime "cancelled_at", precision: nil
    t.integer "cancelled_by_id"
    t.string "publishing_state", default: "published", null: false
    t.string "redirect_url"
    t.string "content_id", null: false
    t.integer "current_release_date_id"
    t.index ["cancelled_by_id"], name: "index_statistics_announcements_on_cancelled_by_id"
    t.index ["creator_id"], name: "index_statistics_announcements_on_creator_id"
    t.index ["current_release_date_id"], name: "index_statistics_announcements_on_current_release_date_id"
    t.index ["publication_id"], name: "index_statistics_announcements_on_publication_id"
    t.index ["slug"], name: "index_statistics_announcements_on_slug"
    t.index ["title"], name: "index_statistics_announcements_on_title"
    t.index ["topic_id"], name: "index_statistics_announcements_on_topic_id"
  end

  create_table "topical_event_about_pages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "topical_event_id"
    t.string "name"
    t.text "summary", size: :medium
    t.text "body", size: :medium
    t.string "read_more_link_text"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "content_id"
  end

  create_table "topical_event_featuring_image_data", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "carrierwave_image"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "topical_event_featurings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "topical_event_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "ordering"
    t.integer "topical_event_featuring_image_data_id"
    t.string "alt_text"
    t.integer "offsite_link_id"
    t.index ["edition_id", "topical_event_id"], name: "index_topical_event_feat_on_edition_id_and_topical_event_id", unique: true
    t.index ["offsite_link_id"], name: "index_topical_event_featurings_on_offsite_link_id"
    t.index ["topical_event_featuring_image_data_id"], name: "index_topical_event_feat_on_topical_event_feat_image_data_id"
    t.index ["topical_event_id"], name: "index_topical_event_feat_on_topical_event_id"
  end

  create_table "topical_event_memberships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "topical_event_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "edition_id"
    t.integer "ordering"
    t.index ["edition_id"], name: "index_topical_event_memberships_on_edition_id"
    t.index ["topical_event_id"], name: "index_topical_event_memberships_on_topical_event_id"
  end

  create_table "topical_event_organisations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "organisation_id", null: false
    t.integer "topical_event_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "ordering"
    t.boolean "lead", default: false, null: false
    t.integer "lead_ordering"
    t.index ["organisation_id", "ordering"], name: "index_topical_event_org_on_organisation_id_and_ordering", unique: true
    t.index ["organisation_id"], name: "index_topical_event_org_on_organisation_id"
    t.index ["topical_event_id"], name: "index_topical_event_org_on_topical_event_id"
  end

  create_table "topical_events", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "description", size: :medium
    t.string "slug"
    t.string "state"
    t.string "logo_alt_text"
    t.date "start_date"
    t.date "end_date"
    t.string "content_id"
    t.text "summary", size: :medium
    t.index ["slug"], name: "index_topical_events_on_slug"
  end

  create_table "unpublishings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "edition_id"
    t.integer "unpublishing_reason_id"
    t.text "explanation", size: :medium
    t.text "alternative_url", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "document_type"
    t.string "slug"
    t.boolean "redirect", default: false
    t.string "content_id", null: false
    t.datetime "unpublished_at", null: false
    t.index ["edition_id"], name: "index_unpublishings_on_edition_id"
    t.index ["unpublishing_reason_id"], name: "index_unpublishings_on_unpublishing_reason_id"
  end

  create_table "user_world_locations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "world_location_id"
    t.index ["user_id", "world_location_id"], name: "index_user_world_locations_on_user_id_and_world_location_id", unique: true
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "email"
    t.string "uid"
    t.integer "version"
    t.text "permissions", size: :medium
    t.boolean "remotely_signed_out", default: false
    t.string "organisation_slug"
    t.boolean "disabled", default: false
    t.index ["disabled"], name: "index_users_on_disabled"
    t.index ["organisation_slug"], name: "index_users_on_organisation_slug"
  end

  create_table "versions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :medium
    t.datetime "created_at", precision: nil
    t.text "state", size: :medium
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "world_location_news", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "world_location_id"
    t.string "content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "world_location_news_translations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "world_location_news_id"
    t.string "locale"
    t.string "title"
    t.text "mission_statement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "world_location_translations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "world_location_id"
    t.string "locale"
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["locale"], name: "index_world_location_translations_on_locale"
    t.index ["world_location_id"], name: "index_world_location_translations_on_world_location_id"
  end

  create_table "world_locations", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug"
    t.boolean "active", default: false, null: false
    t.integer "world_location_type", null: false
    t.string "iso2", limit: 2
    t.string "analytics_identifier"
    t.string "content_id"
    t.index ["iso2"], name: "index_world_locations_on_iso2", unique: true
    t.index ["slug"], name: "index_world_locations_on_slug"
    t.index ["world_location_type"], name: "index_world_locations_on_world_location_type"
  end

  create_table "worldwide_office_worldwide_services", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "worldwide_office_id", null: false
    t.integer "worldwide_service_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "worldwide_offices", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "worldwide_office_type_id", null: false
    t.string "slug"
    t.text "access_and_opening_times", size: :medium
    t.string "content_id"
    t.integer "edition_id"
    t.index ["edition_id"], name: "index_worldwide_offices_on_edition_id"
    t.index ["slug"], name: "index_worldwide_offices_on_slug"
  end

  create_table "worldwide_organisation_page_translations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "worldwide_organisation_page_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "summary"
    t.text "body"
    t.index ["locale"], name: "index_worldwide_organisation_page_translations_on_locale"
    t.index ["worldwide_organisation_page_id"], name: "index_bbd0fc4436b2d97c8b36796e9089468751fc0f2e"
  end

  create_table "worldwide_organisation_pages", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "corporate_information_page_type_id", null: false
    t.integer "edition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_id"
    t.index ["edition_id"], name: "index_worldwide_organisation_pages_on_edition_id"
  end

  create_table "worldwide_services", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "service_type_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  add_foreign_key "content_block_edition_authors", "content_block_editions", column: "edition_id"
  add_foreign_key "content_block_edition_organisations", "content_block_editions"
  add_foreign_key "content_block_editions", "content_block_documents", column: "document_id"
  add_foreign_key "documents", "editions", column: "latest_edition_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "documents", "editions", column: "live_edition_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "editions", "governments", on_delete: :nullify
  add_foreign_key "link_checker_api_report_links", "link_checker_api_reports"
  add_foreign_key "link_checker_api_reports", "editions"
  add_foreign_key "related_mainstreams", "editions"
  add_foreign_key "statistics_announcements", "statistics_announcement_dates", column: "current_release_date_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "worldwide_offices", "editions"
end
