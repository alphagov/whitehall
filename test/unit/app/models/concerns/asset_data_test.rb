require "test_helper"

class AssetDataTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ActionDispatch::TestProcess

  setup do
    AttachmentUploader.enable_processing = true
    @asset_manager_id = "asset_manager_id"
  end

  test "returns its attachable's auth_bypass_id when it has one" do
    auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
    attachable = Publication.new(auth_bypass_id:)
    attachment = build(:attachment_data, attachable:)

    assert_equal [auth_bypass_id], attachment.auth_bypass_ids
  end

  test "#access_limited? is falsey if there is no last attachable" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    assert_not attachment_data.access_limited?
  end

  test "#access_limited? delegates to the last attachable" do
    attachable = stub("attachable", access_limited?: "access-limited")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal "access-limited", attachment_data.access_limited?
  end

  test "#access_limited_object returns nil if there is no last attachable" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])
    assert_nil attachment_data.access_limited_object
  end

  test "#access_limited_object delegates to the last attachable" do
    attachable = stub("attachable", access_limited_object: "access-limited-object")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)
    assert_equal "access-limited-object", attachment_data.access_limited_object
  end

  test "#last_publicly_visible_attachment returns publicly visible attachable" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(true)
    attachment = build(:file_attachment, attachable:)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_equal attachment, attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns latest publicly visible attachable" do
    earliest_attachable = build(:edition)
    earliest_attachable.stubs(:publicly_visible?).returns(true)
    latest_attachable = build(:edition)
    latest_attachable.stubs(:publicly_visible?).returns(true)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: latest_attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal latest_attachment, attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns nil if there are no publicly visible attachables" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    attachment = build(:file_attachment, attachable:)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test "#last_publicly_visible_attachment returns nil if there are no attachables" do
    attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([attachment])

    assert_nil attachment_data.last_publicly_visible_attachment
  end

  test "#last_attachment returns attachment for latest attachable" do
    earliest_attachable = build(:edition)
    latest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: latest_attachable)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal latest_attachment, attachment_data.last_attachment
  end

  test "#last_attachment ignores attachments without attachable" do
    earliest_attachable = build(:edition)
    earliest_attachment = build(:file_attachment, attachable: earliest_attachable)
    latest_attachment = build(:file_attachment, attachable: nil)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([earliest_attachment, latest_attachment])

    assert_equal earliest_attachment, attachment_data.last_attachment
  end

  test "#last_attachment returns null attachment if no attachments" do
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([])

    assert_instance_of Attachment::Null, attachment_data.last_attachment
  end

  test "#deleted? returns true if attachment is deleted" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable:, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test "#deleted? returns false if attachment is not deleted" do
    attachable = build(:edition)
    attachable.stubs(:publicly_visible?).returns(false)
    deleted_attachment = build(:file_attachment, attachable:, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert_not attachment_data.deleted?
  end

  test "#deleted? returns true if attachment is deleted even if attachable is nil" do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: true)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert attachment_data.deleted?
  end

  test "#deleted? returns false if attachment is not deleted even if attachable is nil" do
    deleted_attachment = build(:file_attachment, attachable: nil, deleted: false)
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:attachments).returns([deleted_attachment])

    assert_not attachment_data.deleted?
  end

  test "#deleted? returns false for AttachmentData with multiple attachments, if the draft edition has not been published yet" do
    attachable = create(:published_publication, :with_file_attachment)
    new_attachable = attachable.reload.create_draft(create(:gds_editor))

    assert_equal new_attachable.attachments.count, 1

    attachment = new_attachable.attachments.first
    attachment.destroy!

    assert_not attachment.reload.attachment_data.deleted?
  end

  test "#deleted? returns true for AttachmentData with multiple attachments, if they are all on live attachables" do
    attachable = create(:published_publication, :with_file_attachment)
    new_attachable = attachable.reload.create_draft(create(:gds_editor))
    attachment = new_attachable.attachments.first
    attachment.destroy!
    new_attachable.update!(minor_change: true)
    new_attachable.force_publish!

    assert attachment.reload.attachment_data.deleted?
  end

  test "#access_limitation_organisation_ids returns an empty array when there are no access limiting organisations" do
    attachable = stub("attachable", access_limited?: true, access_limited_object: "access-limited-object")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)

    AssetManagerAccessLimitation.expects(:for).with("access-limited-object", :organisations).returns(nil)

    assert_empty attachment_data.access_limitation_organisation_ids
  end

  test "#access_limitation_individual_ids returns an empty array when there are no access limiting individuals" do
    attachable = stub("attachable", access_limited?: true, access_limited_object: "access-limited-object")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)

    AssetManagerAccessLimitation.expects(:for).with("access-limited-object", :users).returns(nil)

    assert_empty attachment_data.access_limitation_individual_ids
  end

  test "#access_limitation_organisation_ids returns the last attachable's access limiting organisations" do
    attachable = stub("attachable", access_limited?: true, access_limited_object: "access-limited-object")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)

    AssetManagerAccessLimitation.expects(:for).with("access-limited-object", :organisations).returns(%w[content-id-1 content-id-2])

    assert_equal %w[content-id-1 content-id-2], attachment_data.access_limitation_organisation_ids
  end

  test "#access_limitation_individual_ids returns the last attachable's access limiting individuals" do
    attachable = stub("attachable", access_limited?: true, access_limited_object: "access-limited-object")
    attachment_data = build(:attachment_data)
    attachment_data.stubs(:last_attachable).returns(attachable)

    AssetManagerAccessLimitation.expects(:for).with("access-limited-object", :users).returns(%w[user-uid-1 user-uid-2])

    assert_equal %w[user-uid-1 user-uid-2], attachment_data.access_limitation_individual_ids
  end

  context "#attachable_url" do
    context "when the attachable is an edition" do
      it "returns draft url for pre-publication edition" do
        edition = create(:draft_standard_edition, :with_file_attachment)
        attachment_data = edition.attachments.first.attachment_data

        assert_equal edition.public_url(draft: true), attachment_data.attachable_url
      end

      Edition::PUBLICLY_VISIBLE_STATES.each do |state|
        it "returns live url for #{state} edition" do
          edition = create(:"#{state}_standard_edition", :with_file_attachment)
          attachment_data = edition.attachments.first.attachment_data

          assert_equal edition.public_url, attachment_data.attachable_url
        end
      end

      it "returns nil for deleted edition" do
        edition = create(:draft_standard_edition, :with_file_attachment)
        attachment_data = edition.attachments.first.attachment_data
        assert attachment_data.attachments.first.attachable

        edition.destroy!
        edition.delete_all_attachments

        assert_equal true, attachment_data.reload.attachments.first.deleted?
        assert_nil attachment_data.attachments.first.attachable
        assert_nil attachment_data.attachable_url
      end

      it "returns nil for unpublished edition" do
        edition = create(:unpublished_standard_edition, :with_file_attachment)
        attachment_data = edition.attachments.first.attachment_data

        assert_nil attachment_data.attachable_url
      end
    end

    context "when the attachable is a consultation or call for evidence outcome" do
      %w[consultation call_for_evidence].each do |parent_attachable_type|
        context "when the attachable is a #{parent_attachable_type} outcome" do
          Edition::PRE_PUBLICATION_STATES.each do |state|
            it "returns draft url for #{state} #{parent_attachable_type}" do
              edition = create(:"#{state}_#{parent_attachable_type}")
              outcome = create(:"#{parent_attachable_type}_outcome", :with_file_attachment, "#{parent_attachable_type}": edition)
              attachment_data = outcome.attachments.first.attachment_data

              assert_equal edition.public_url(draft: true), attachment_data.attachable_url
            end
          end

          Edition::PUBLICLY_VISIBLE_STATES.each do |state|
            it "returns live url for #{state} #{parent_attachable_type}" do
              edition = create(:"#{state}_#{parent_attachable_type}")
              outcome = create(:"#{parent_attachable_type}_outcome", :with_file_attachment, "#{parent_attachable_type}": edition)
              attachment_data = outcome.attachments.first.attachment_data

              assert_equal edition.public_url, attachment_data.attachable_url
            end
          end

          it "returns nil for deleted #{parent_attachable_type}" do
            edition = create(:"#{parent_attachable_type}")
            outcome = create(:"#{parent_attachable_type}_outcome", :with_file_attachment, "#{parent_attachable_type}": edition)
            attachment_data = outcome.attachments.first.attachment_data
            assert attachment_data.attachments.first.attachable

            edition.destroy!
            edition.delete_all_attachments

            assert_equal true, attachment_data.reload.attachments.first.deleted?
            assert_nil attachment_data.attachments.first.attachable
            assert_nil attachment_data.attachable_url
          end

          it "returns nil for unpublished #{parent_attachable_type}" do
            edition = create(:"unpublished_#{parent_attachable_type}")
            outcome = create(:"#{parent_attachable_type}_outcome", :with_file_attachment, "#{parent_attachable_type}": edition)
            attachment_data = outcome.attachments.first.attachment_data

            assert_nil attachment_data.attachable_url
          end
        end
      end
    end

    context "when the attachable is a policy group" do
      it "returns live url" do
        policy_group = create(:policy_group, :with_file_attachment)
        attachment_data = policy_group.attachments.first.attachment_data

        assert_equal policy_group.public_url, attachment_data.attachable_url
      end

      it "returns nil for deleted policy group" do
        policy_group = create(:policy_group, :with_file_attachment)
        attachment_data = policy_group.attachments.first.attachment_data
        assert attachment_data.attachments.first.attachable

        policy_group.destroy!
        policy_group.delete_all_attachments

        assert_equal true, attachment_data.reload.attachments.first.deleted?
        assert_nil attachment_data.attachments.first.attachable
        assert_nil attachment_data.attachable_url
      end
    end
  end
end
