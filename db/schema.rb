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

ActiveRecord::Schema.define(:version => 20111025151004) do

  create_table "attachments", :force => true do |t|
    t.string   "carrierwave_file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_identities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "document_identities", ["slug"], :name => "index_document_identities_on_slug", :unique => true

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
  end

  create_table "document_relations", :force => true do |t|
    t.integer  "document_id",         :null => false
    t.integer  "related_document_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_topics", :id => false, :force => true do |t|
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "document_id"
  end

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.boolean  "submitted",            :default => false
    t.integer  "lock_version",         :default => 0
    t.integer  "document_identity_id"
    t.string   "state",                :default => "draft", :null => false
    t.integer  "attachment_id"
    t.string   "type"
    t.integer  "role_appointment_id"
    t.string   "location"
    t.date     "delivered_on"
    t.date     "opening_on"
    t.date     "closing_on"
  end

  create_table "fact_check_requests", :force => true do |t|
    t.integer  "document_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address"
    t.text     "comments"
    t.text     "instructions"
  end

  add_index "fact_check_requests", ["key"], :name => "index_fact_check_requests_on_key", :unique => true

  create_table "nation_inapplicabilities", :force => true do |t|
    t.integer  "nation_id"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nations", :force => true do |t|
    t.string "name"
  end

  create_table "organisation_roles", :force => true do |t|
    t.integer  "organisation_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.text     "address"
    t.string   "postcode"
    t.decimal  "latitude",   :precision => 15, :scale => 10
    t.decimal  "longitude",  :precision => 15, :scale => 10
    t.string   "slug"
  end

  add_index "organisations", ["slug"], :name => "index_organisations_on_slug"

  create_table "people", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "privy_councillor", :default => false
  end

  create_table "phone_numbers", :force => true do |t|
    t.integer "organisation_id"
    t.string  "number"
    t.string  "description"
  end

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
    t.string   "type",       :default => "MinisterialRole", :null => false
    t.boolean  "leader",     :default => false
    t.string   "slug"
  end

  add_index "roles", ["slug"], :name => "index_roles_on_slug"

  create_table "supporting_documents", :force => true do |t|
    t.integer  "document_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0
    t.string   "slug"
  end

  add_index "supporting_documents", ["slug"], :name => "index_supporting_documents_on_slug"

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "slug"
  end

  add_index "topics", ["slug"], :name => "index_topics_on_slug"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "departmental_editor", :default => false
  end

end
