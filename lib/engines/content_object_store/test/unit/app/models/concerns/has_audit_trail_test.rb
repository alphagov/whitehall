require "test_helper"

class ContentObjectStore::HasAuditTrailTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "record_create" do
    it "creates a 'created' version with the current user" do
      user = create("user")
      Current.user = user
      edition = create(
        :content_block_edition,
        creator: user,
        document: create(:content_block_document, :email_address),
      )
      version = edition.versions.first

      assert_equal user.id.to_s, version.whodunnit
      assert_equal "created", version.event
    end
  end

  describe "versions" do
    it "returns versions in descending order based on datetime" do
      edition = create(
        :content_block_edition,
        document: create(:content_block_document, :email_address),
      )
      newer_version = edition.versions.first
      oldest_version = create(
        :content_block_version,
        created_at: 2.days.ago,
        item: edition,
      )
      middle_version = create(
        :content_block_version,
        created_at: 1.day.ago,
        item: edition,
      )
      assert_equal edition.versions.first, newer_version
      assert_equal edition.versions.last, oldest_version
      assert_equal edition.versions[1], middle_version
    end

    it "returns versions in descending order based on id" do
      edition = create(
        :content_block_edition,
        document: create(:content_block_document, :email_address),
      )
      first_version = edition.versions.first
      second_version = create(
        :content_block_version,
        item: edition,
      )
      third_version = create(
        :content_block_version,
        item: edition,
      )
      assert_equal edition.versions.first, third_version
      assert_equal edition.versions[1], second_version
      assert_equal edition.versions.last, first_version
    end
  end
end
