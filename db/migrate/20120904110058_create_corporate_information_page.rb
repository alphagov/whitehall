class CreateCorporateInformationPage < ActiveRecord::Migration
  def change
    create_table "corporate_information_page_attachments" do |t|
      t.integer  "corporate_information_page_id"
      t.integer  "attachment_id"
      t.timestamps
    end

    add_index "corporate_information_page_attachments", ["attachment_id"], name: "corporate_information_page_attachments_a_id"
    add_index "corporate_information_page_attachments", ["corporate_information_page_id"], name: "corporate_information_page_attachments_ci_id"


    create_table "corporate_information_pages" do |t|
      t.integer  "lock_version"
      t.integer  "organisation_id"
      t.integer  "type_id"
      t.text     "summary"
      t.text     "body"
      t.timestamps
    end

    add_index "corporate_information_pages", ["organisation_id", "type_id"], unique: true
  end
end
