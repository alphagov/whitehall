require "test_helper"

class ContentBlockManager::HasAuditTrailTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { create("user") }

  describe "record_create" do
    it "creates a 'created' version with the current user" do
      Current.user = user
      edition = build(
        :content_block_edition,
        creator: user,
        document: create(:content_block_document, :email_address),
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
        document: create(:content_block_document, :email_address),
      )
      edition.scheduled_publication = Time.zone.now

      assert_changes -> { edition.versions.count }, from: 1, to: 2 do
        edition.schedule!
      end

      version = edition.versions.first

      assert_equal user.id.to_s, version.whodunnit
      assert_equal "updated", version.event
      assert_equal "scheduled", version.state
    end

    it "does not record a version when updating an existing draft" do
      edition = create(
        :content_block_edition,
        document: create(:content_block_document, :email_address),
        state: "draft",
      )

      assert_no_changes -> { edition.versions.count } do
        edition.update!(details: { "foo": "bar" })
      end
    end

    describe "when there are changes to the content of a block" do
      describe "when a top level field on an edition has changed" do
        %w[title instructions_to_publishers].each do |field|
          it "records the changes" do
            old_value = "old_value"
            new_value = "new_value"
            Current.user = user
            organisation = build(:organisation)
            document = create(:content_block_document, :email_address)
            previous_edition = create(
              :content_block_edition,
              creator: user,
              document:,
              organisation:,
            )
            previous_edition.update!(field => old_value)
            new_edition = create(
              :content_block_edition,
              creator: user,
              document:,
              state: "draft",
              organisation:,
            )
            new_edition.update!(field => new_value)

            new_edition.publish!

            version = new_edition.versions.first

            assert_equal version.changed_fields, [{ "field_name" => field, "previous" => old_value, "new" => new_value }]
          end
        end

        describe "when the organisation has changed" do
          it "records the changes" do
            old_organisation = build(:organisation, id: "123", name: "Old Organisation")
            Organisation.expects(:find).with(old_organisation.id).returns(old_organisation)

            Current.user = user
            document = create(:content_block_document, :email_address)
            _previous_edition = create(
              :content_block_edition,
              creator: user,
              document:,
              organisation: old_organisation,
            )
            new_edition = create(
              :content_block_edition,
              creator: user,
              document:,
              state: "draft",
              organisation: build(:organisation, name: "New Organisation", id: "456"),
            )

            new_edition.publish!

            version = new_edition.versions.first

            assert_equal version.changed_fields, [{ "field_name" => "lead_organisation", "previous" => "Old Organisation", "new" => "New Organisation" }]
          end
        end
      end

      describe "when a field in the edition details has changed" do
        it "records the changes" do
          organisation = build(:organisation)

          Current.user = user
          document = create(:content_block_document, :email_address)
          _previous_edition = create(
            :content_block_edition,
            creator: user,
            document:,
            title: "same title",
            instructions_to_publishers: "same instructions",
            details: { "email_address": "old@example.com" },
            organisation:,
          )
          new_edition = create(
            :content_block_edition,
            creator: user,
            document:,
            title: "same title",
            instructions_to_publishers: "same instructions",
            details: { "email_address": "new@example.com" },
            state: "draft",
            organisation:,
          )

          new_edition.publish!

          version = new_edition.versions.first

          assert_equal version.changed_fields, [{ "field_name" => "email_address", "new" => "new@example.com", "previous" => "old@example.com" }]
        end
      end
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
