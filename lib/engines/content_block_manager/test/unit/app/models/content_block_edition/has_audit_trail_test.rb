require "test_helper"

class ContentBlockManager::HasAuditTrailTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { create("user") }
  let(:organisation) { build(:organisation) }
  let(:document) { build(:content_block_document, :pension) }

  describe "record_create" do
    it "creates a 'created' version with the current user" do
      Current.user = user
      edition = build(
        :content_block_edition,
        creator: user,
        document: create(:content_block_document, :pension),
      )

      assert_changes -> { edition.versions.count }, from: 0, to: 1 do
        edition.save
      end

      version = edition.versions.first

      assert_equal user.id.to_s, version.whodunnit
      assert_equal "created", version.event
    end
  end

  describe "record_update" do
    it "creates a 'updated' version after scheduling an edition" do
      Current.user = user
      edition = create(
        :content_block_edition,
        creator: user,
        document: create(:content_block_document, :pension),
      )
      edition.scheduled_publication = Time.zone.now
      edition.expects(:generate_diff).returns({})

      assert_changes -> { edition.versions.count }, from: 1, to: 2 do
        edition.schedule!
      end

      version = edition.versions.first

      assert_equal user.id.to_s, version.whodunnit
      assert_equal "updated", version.event
      assert_equal "scheduled", version.state
    end

    it "adds event details if provided" do
      Current.user = user
      edition = create(
        :content_block_edition,
        creator: user,
        document: create(:content_block_document, :pension),
      )
      edition.expects(:generate_diff).returns({})
      edition.updated_embedded_object_type = "something"
      edition.updated_embedded_object_title = "here"

      assert_changes -> { edition.versions.count }, from: 1, to: 2 do
        edition.publish!
      end

      version = edition.versions.first

      assert_equal edition.updated_embedded_object_type, version.updated_embedded_object_type
      assert_equal edition.updated_embedded_object_title, version.updated_embedded_object_title
    end

    it "does not record a version when updating an existing draft" do
      edition = create(
        :content_block_edition,
        document: create(:content_block_document, :pension),
        state: "draft",
      )

      assert_no_changes -> { edition.versions.count } do
        edition.update!(details: { "foo": "bar" })
      end
    end

    it "checks for any field_diffs" do
      Current.user = user
      edition = create(
        :content_block_edition,
        creator: user,
        document: create(:content_block_document, :pension),
      )
      edition.scheduled_publication = Time.zone.now

      edition.expects(:generate_diff).returns({})
      edition.schedule!
    end
  end

  describe "acting_as" do
    def setup
      @user = create(:user)
      @user2 = create(:user)
    end

    test "changes Current.user for the duration of the block, reverting to the original user afterwards" do
      Current.user = @user

      ContentBlockManager::ContentBlock::Edition::HasAuditTrail.acting_as(@user2) do
        assert_equal @user2, Current.user
      end

      assert_equal @user, Current.user
    end

    test "reverts Current.user, even when an exception is thrown" do
      Current.user = @user

      assert_raises do
        ContentBlockManager::ContentBlock::Edition::HasAuditTrail.acting_as(@user2) { raise "Boom!" }
      end

      assert_equal @user, Current.user
    end
  end

  describe "versions" do
    it "returns versions in descending order based on datetime" do
      edition = create(
        :content_block_edition,
        document: create(:content_block_document, :pension),
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
        document: create(:content_block_document, :pension),
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
