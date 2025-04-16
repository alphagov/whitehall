require "test_helper"
require "rake"

class WhitehallContactsReportTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    Rake::Task["content_block_manager:whitehall_contacts_report"].reenable
  end

  describe "adds Contact info to CSV" do
    let!(:org_1) { create(:organisation, name: "Org 1") }
    let!(:contact_1) { create(:contact, contactable: org_1, contact_numbers: [create(:contact_number, label: "Phone", number: "456")]) }
    let!(:org_2) { create(:organisation, name: "Org 2") }
    let!(:office_1) { create(:worldwide_office, title: "Office 1") }
    let!(:contact_2) { create(:contact, contactable: office_1, contact_numbers: [create(:contact_number, label: "Fax", number: "123")]) }
    let!(:office_2) { create(:worldwide_office, title: "Office 2") }

    it "adds to csd" do
      file_path = "#{Rails.root}/tmp/2025-04-09-contacts.csv"

      Rake::Task["content_block_manager:whitehall_contacts_report"].execute

      assert_includes File.read(file_path), "Org 1"
      assert_includes File.read(file_path), "Office 1"
    end

  end

end