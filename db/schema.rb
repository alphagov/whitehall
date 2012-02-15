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

ActiveRecord::Schema.define(:version => 20120215114920) do

  create_table "attachments", :force => true do |t|
    t.string   "carrierwave_file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "number_of_pages"
    t.string   "title"
  end

  create_table "contact_numbers", :force => true do |t|
    t.integer  "contact_id"
    t.string   "label"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.integer "organisation_id"
    t.string  "description"
    t.text    "address"
    t.string  "postcode"
    t.decimal "latitude",        :precision => 15, :scale => 10
    t.decimal "longitude",       :precision => 15, :scale => 10
    t.string  "email"
  end

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "embassy_address"
    t.string   "embassy_telephone"
    t.string   "embassy_email"
    t.string   "slug"
    t.text     "description"
    t.text     "about"
    t.boolean  "active",            :default => false, :null => false
  end

  add_index "countries", ["slug"], :name => "index_countries_on_slug"

  create_table "document_attachments", :force => true do |t|
    t.integer  "document_id"
    t.integer  "attachment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_authors", :force => true do |t|
    t.integer  "document_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_countries", :force => true do |t|
    t.integer  "document_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_identities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "document_type"
  end

  add_index "document_identities", ["slug", "document_type"], :name => "index_document_identities_on_slug_and_document_type", :unique => true

  create_table "document_ministerial_roles", :force => true do |t|
    t.integer  "document_id"
    t.integer  "ministerial_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_organisations", :force => true do |t|
    t.integer  "document_id"
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",        :default => false
  end

  create_table "document_relations", :force => true do |t|
    t.integer  "document_id",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "document_identity_id"
  end

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",                      :default => 0
    t.integer  "document_identity_id"
    t.string   "state",                             :default => "draft", :null => false
    t.string   "type"
    t.integer  "role_appointment_id"
    t.string   "location"
    t.date     "delivered_on"
    t.date     "opening_on"
    t.date     "closing_on"
    t.datetime "published_at"
    t.datetime "first_published_at"
    t.date     "publication_date"
    t.string   "unique_reference"
    t.string   "isbn"
    t.boolean  "research",                          :default => false
    t.string   "order_url"
    t.text     "notes_to_editors"
    t.boolean  "corporate_publication",             :default => false
    t.text     "summary"
    t.integer  "speech_type_id"
    t.integer  "consultation_document_identity_id"
    t.string   "carrierwave_image"
    t.boolean  "featured",                          :default => false
    t.string   "carrierwave_featuring_image"
    t.text     "image_caption"
    t.boolean  "stub",                              :default => false
    t.text     "change_note"
    t.boolean  "force_published"
    t.string   "image_alt_text"
  end

  create_table "editorial_remarks", :force => true do |t|
    t.text     "body"
    t.integer  "document_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fact_check_requests", :force => true do |t|
    t.integer  "document_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address"
    t.text     "comments"
    t.text     "instructions"
    t.integer  "requestor_id"
  end

  add_index "fact_check_requests", ["key"], :name => "index_fact_check_requests_on_key", :unique => true

  create_table "image_data", :force => true do |t|
    t.string   "carrierwave_image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "image_data_id"
    t.integer  "document_id"
    t.string   "alt_text"
    t.text     "caption"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nation_inapplicabilities", :force => true do |t|
    t.integer  "nation_id"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alternative_url"
  end

  create_table "nations", :force => true do |t|
    t.string "name"
  end

  create_table "organisation_policy_areas", :force => true do |t|
    t.integer  "organisation_id", :null => false
    t.integer  "policy_area_id",  :null => false
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

  create_table "organisation_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean  "active",               :default => false, :null => false
    t.text     "logo_formatted_name"
  end

  add_index "organisations", ["slug"], :name => "index_organisations_on_slug"

  create_table "people", :force => true do |t|
    t.string   "title"
    t.string   "forename"
    t.string   "surname"
    t.string   "letters"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "privy_councillor",  :default => false
    t.string   "carrierwave_image"
    t.text     "biography"
  end

  create_table "policy_area_memberships", :force => true do |t|
    t.integer  "policy_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "policy_id"
    t.integer  "ordering"
    t.boolean  "featured",       :default => false
  end

  create_table "policy_area_relations", :force => true do |t|
    t.integer  "policy_area_id",         :null => false
    t.integer  "related_policy_area_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "policy_areas", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
    t.boolean  "featured",    :default => false
    t.string   "state"
  end

  add_index "policy_areas", ["slug"], :name => "index_policy_areas_on_slug"

  create_table "role_appointments", :force => true do |t|
    t.integer  "role_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  create_table "roles", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "type",                :default => "MinisterialRole", :null => false
    t.boolean  "permanent_secretary", :default => false
    t.boolean  "cabinet_member",      :default => false,             :null => false
    t.string   "slug"
    t.text     "responsibilities"
  end

  add_index "roles", ["slug"], :name => "index_roles_on_slug"

  create_table "speech_types", :force => true do |t|
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

  create_table "supporting_pages", :force => true do |t|
    t.integer  "document_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
    t.string   "slug"
  end

  add_index "supporting_pages", ["slug"], :name => "index_supporting_documents_on_slug"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "departmental_editor", :default => false
    t.string   "email"
    t.integer  "organisation_id"
    t.string   "uid"
    t.integer  "version"
  end

end
