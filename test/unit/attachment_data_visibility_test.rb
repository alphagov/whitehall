require 'test_helper'

class AttachmentDataVisibilityTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:organisation) { create(:organisation) }
  let(:user) { create(:writer, organisation: organisation) }
  let(:user_in_same_organisation) { create(:writer, organisation: organisation) }
  let(:another_organisation) { create(:organisation) }
  let(:user_in_another_organisation) { create(:writer, organisation: another_organisation) }
  let(:anonymous_user) { nil }

  context 'given an attachment' do
    let(:file) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { build(:file_attachment, attachable: attachable, file: file) }
    let(:attachment_data) { attachment.attachment_data }

    before do
      attachable.attachments << attachment
      VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    end

    context 'on a draft edition' do
      let(:edition) { create(:news_article, organisations: [organisation]) }
      let(:attachable) { edition }

      it 'is not deleted' do
        refute attachment_data.reload.deleted?
      end

      it 'is draft' do
        assert attachment_data.reload.draft?
      end

      it 'is not accessible to anonymous user' do
        refute attachment_data.reload.accessible_to?(anonymous_user)
      end

      it 'is accessible to user in same organisation' do
        assert attachment_data.reload.accessible_to?(user_in_same_organisation)
      end

      it 'is accessible to user in another organisation' do
        assert attachment_data.reload.accessible_to?(user_in_another_organisation)
      end

      it 'is not unpublished' do
        refute attachment_data.reload.unpublished?
      end

      it 'has no unpublished edition' do
        assert_nil attachment_data.reload.unpublished_edition
      end

      it 'is not replaced' do
        refute attachment_data.reload.replaced?
      end

      context 'edition is access-limited' do
        before do
          edition.access_limited = true
          edition.save!
        end

        it 'is not accessible to anonymous user' do
          refute attachment_data.reload.accessible_to?(anonymous_user)
        end

        it 'is accessible to user in same organisation' do
          assert attachment_data.reload.accessible_to?(user_in_same_organisation)
        end

        it 'is not accessible to user in another organisation' do
          refute attachment_data.reload.accessible_to?(user_in_another_organisation)
        end

        context 'when edition is published' do
          before do
            edition.major_change_published_at = Time.zone.now
            edition.force_publish!
          end

          context 'and new edition is created' do
            let(:new_edition) { edition.create_draft(user) }

            before do
              new_edition.reload
            end

            context 'new edition is access-limited' do
              before do
                new_edition.change_note = 'change-note'
                new_edition.access_limited = true
                new_edition.save!
              end

              context 'discard new edition' do
                before do
                  new_edition.delete
                  new_edition.save!
                end

                it 'is access limited' do
                  assert attachment_data.reload.access_limited?
                end
              end
            end
          end
        end
      end

      context 'when attachment is deleted' do
        before do
          attachment.destroy!
        end

        it 'is deleted' do
          assert attachment_data.reload.deleted?
        end
      end

      context 'when attachment is replaced' do
        before do
          attributes = attributes_for(:attachment_data)
          attributes[:to_replace_id] = attachment_data.id
          attachment.update_attributes!(attachment_data_attributes: attributes)
        end

        it 'is not deleted' do
          refute attachment_data.reload.deleted?
        end

        it 'is draft' do
          assert attachment_data.reload.draft?
        end

        it 'is replaced' do
          assert attachment_data.reload.replaced?
        end

        context 'when edition is published' do
          before do
            edition.major_change_published_at = Time.zone.now
            edition.force_publish!
          end

          it 'is not deleted' do
            refute attachment_data.reload.deleted?
          end

          it 'is draft' do
            assert attachment_data.reload.draft?
          end

          it 'is replaced' do
            assert attachment_data.reload.replaced?
          end
        end
      end

      context 'when edition is published' do
        before do
          edition.major_change_published_at = Time.zone.now
          edition.force_publish!
        end

        it 'is not deleted' do
          refute attachment_data.reload.deleted?
        end

        it 'is not draft' do
          refute attachment_data.reload.draft?
        end

        it 'is not unpublished' do
          refute attachment_data.reload.unpublished?
        end

        it 'has no unpublished edition' do
          assert_nil attachment_data.reload.unpublished_edition
        end

        context 'and new edition is created' do
          let(:new_edition) { edition.create_draft(user) }
          let(:new_attachable) { new_edition }
          let(:new_attachment) { new_attachable.attachments.first }

          before do
            new_edition.reload
          end

          it 'is not deleted' do
            refute attachment_data.reload.deleted?
          end

          it 'is not draft' do
            refute attachment_data.reload.draft?
          end

          it 'is not unpublished' do
            refute attachment_data.reload.unpublished?
          end

          it 'has no unpublished edition' do
            assert_nil attachment_data.reload.unpublished_edition
          end

          context 'when new edition is discarded' do
            before do
              new_edition.delete
              new_edition.save!
            end

            it 'is not deleted' do
              refute attachment_data.reload.deleted?
            end

            context 'and another new edition is created' do
              let(:another_new_edition) { edition.create_draft(user) }

              before do
                another_new_edition.reload
              end

              it 'is not deleted' do
                refute attachment_data.reload.deleted?
              end

              it 'is not draft' do
                refute attachment_data.reload.draft?
              end
            end
          end

          context 'new edition is access-limited' do
            before do
              new_edition.change_note = 'change-note'
              new_edition.access_limited = true
              new_edition.save!
            end

            it 'is not accessible to anonymous user' do
              refute attachment_data.reload.accessible_to?(anonymous_user)
            end

            it 'is accessible to user in same organisation' do
              assert attachment_data.reload.accessible_to?(user_in_same_organisation)
            end

            it 'is accessible to user in another organisation' do
              assert attachment_data.reload.accessible_to?(user_in_another_organisation)
            end
          end

          context 'when attachment is replaced' do
            before do
              attributes = attributes_for(:attachment_data)
              attributes[:to_replace_id] = attachment_data.id
              new_attachment.update_attributes!(attachment_data_attributes: attributes)
            end

            it 'is not deleted' do
              refute attachment_data.reload.deleted?
            end

            it 'is not draft, because available on published edition' do
              refute attachment_data.reload.draft?
            end

            it 'is replaced' do
              assert attachment_data.reload.replaced?
            end
          end

          context 'and attachment is deleted' do
            before do
              new_attachment.destroy!
            end

            it 'is not deleted, because available on published edition' do
              refute attachment_data.reload.deleted?
            end

            it 'is not draft, because available on published edition' do
              refute attachment_data.reload.draft?
            end

            context 'and new edition is published' do
              before do
                new_edition.major_change_published_at = Time.zone.now
                new_edition.change_note = 'change-note'
                new_edition.force_publish!
              end

              it 'is deleted, because not available on published edition' do
                assert attachment_data.reload.deleted?
              end
            end
          end
        end

        context 'and edition is unpublished' do
          before do
            attributes = attributes_for(:unpublishing, edition: edition)
            edition.build_unpublishing(attributes)
            edition.unpublish!
          end

          it 'is not deleted' do
            refute attachment_data.reload.deleted?
          end

          it 'is draft' do
            assert attachment_data.reload.draft?
          end

          it 'is is unpublished' do
            assert attachment_data.reload.unpublished?
          end

          it 'returns edition as unpublished edition' do
            assert_equal edition, attachment_data.reload.unpublished_edition
          end
        end

        context 'and edition is withdrawn' do
          before do
            attributes = attributes_for(:unpublishing, edition: edition)
            edition.build_unpublishing(attributes)
            edition.withdraw!
          end

          it 'is not deleted' do
            refute attachment_data.reload.deleted?
          end

          it 'is not draft' do
            refute attachment_data.reload.draft?
          end

          it 'is is not unpublished' do
            refute attachment_data.reload.unpublished?
          end

          it 'has no unpublished edition' do
            assert_nil attachment_data.reload.unpublished_edition
          end
        end
      end
    end

    context 'on a draft consultation response' do
      let(:consultation) { create(:consultation, organisations: [organisation]) }
      let(:outcome_attributes) { attributes_for(:consultation_outcome) }
      let(:outcome) { consultation.create_outcome!(outcome_attributes) }
      let(:attachable) { outcome }

      it 'is not deleted' do
        refute attachment_data.reload.deleted?
      end

      it 'is draft' do
        assert attachment_data.reload.draft?
      end

      it 'is not accessible to anonymous user' do
        refute attachment_data.reload.accessible_to?(anonymous_user)
      end

      it 'is accessible to user in same organisation' do
        assert attachment_data.reload.accessible_to?(user_in_same_organisation)
      end

      it 'is accessible to user in another organisation' do
        assert attachment_data.reload.accessible_to?(user_in_another_organisation)
      end

      it 'is not unpublished' do
        refute attachment_data.reload.unpublished?
      end

      it 'has no unpublished edition' do
        assert_nil attachment_data.reload.unpublished_edition
      end

      context 'consultation is access-limited' do
        before do
          consultation.update_attributes!(access_limited: true)
        end

        it 'is not accessible to anonymous user' do
          refute attachment_data.reload.accessible_to?(anonymous_user)
        end

        it 'is accessible to user in same organisation' do
          assert attachment_data.reload.accessible_to?(user_in_same_organisation)
        end

        it 'is not accessible to user in another organisation' do
          refute attachment_data.reload.accessible_to?(user_in_another_organisation)
        end
      end

      context 'when attachment is deleted' do
        before do
          attachment.destroy!
        end

        it 'is deleted' do
          assert attachment_data.reload.deleted?
        end
      end

      context 'when consultation is published' do
        before do
          consultation.major_change_published_at = Time.zone.now
          consultation.force_publish!
        end

        it 'is not deleted' do
          refute attachment_data.reload.deleted?
        end

        it 'is not draft' do
          refute attachment_data.reload.draft?
        end

        it 'is not unpublished' do
          refute attachment_data.reload.unpublished?
        end

        it 'has no unpublished edition' do
          assert_nil attachment_data.reload.unpublished_edition
        end

        context 'and new edition is created' do
          let(:new_edition) { consultation.create_draft(user) }
          let(:new_attachable) { new_edition.outcome }
          let(:new_attachment) { new_attachable.attachments.first }

          before do
            new_edition.reload
          end

          it 'is not deleted' do
            refute attachment_data.reload.deleted?
          end

          it 'is not draft' do
            refute attachment_data.reload.draft?
          end

          it 'is not unpublished' do
            refute attachment_data.reload.unpublished?
          end

          it 'has no unpublished edition' do
            assert_nil attachment_data.reload.unpublished_edition
          end

          context 'when new edition is discarded' do
            before do
              new_edition.delete
              new_edition.save!
            end

            it 'is not deleted' do
              refute attachment_data.reload.deleted?
            end
          end

          context 'and attachment is deleted' do
            before do
              new_attachment.destroy!
            end

            it 'is not deleted, because available on published edition' do
              refute attachment_data.reload.deleted?
            end

            it 'is not draft, because available on published edition' do
              refute attachment_data.reload.draft?
            end

            context 'and new edition is published' do
              before do
                new_edition.major_change_published_at = Time.zone.now
                new_edition.change_note = 'change-note'
                new_edition.force_publish!
              end

              it 'is deleted, because not available on published edition' do
                assert attachment_data.reload.deleted?
              end
            end
          end
        end

        context 'and consultation is unpublished' do
          before do
            attributes = attributes_for(:unpublishing, edition: consultation)
            consultation.build_unpublishing(attributes)
            consultation.unpublish!
          end

          it 'is not deleted' do
            refute attachment_data.reload.deleted?
          end

          it 'is draft' do
            assert attachment_data.reload.draft?
          end

          it 'is unpublished' do
            assert attachment_data.reload.unpublished?
          end

          it 'returns consultation as unpublished edition' do
            assert_equal consultation, attachment_data.reload.unpublished_edition
          end
        end
      end
    end

    context 'on a policy group' do
      let(:policy_group) { create(:policy_group) }
      let(:attachable) { policy_group }

      it 'is not deleted' do
        refute attachment_data.reload.deleted?
      end

      it 'is not draft' do
        refute attachment_data.reload.draft?
      end

      it 'is not unpublished' do
        refute attachment_data.reload.unpublished?
      end

      it 'has no unpublished edition' do
        assert_nil attachment_data.reload.unpublished_edition
      end

      it 'is accessible to anonymous user' do
        assert attachment_data.reload.accessible_to?(anonymous_user)
      end

      it 'is accessible to user in same organisation' do
        assert attachment_data.reload.accessible_to?(user_in_same_organisation)
      end

      it 'is accessible to user in another organisation' do
        assert attachment_data.reload.accessible_to?(user_in_another_organisation)
      end

      context 'when attachment is deleted' do
        before do
          attachment.destroy!
        end

        it 'is deleted' do
          assert attachment_data.reload.deleted?
        end
      end
    end

    context 'when attachment data would otherwise be visible' do
      let(:attachable) { build(:news_article) }

      let(:deleted) { false }
      let(:draft) { false }

      before do
        attachment_data.stubs(
          deleted?: deleted,
          draft?: draft
        )
      end

      it 'is visible' do
        assert attachment_data.visible_to?(nil)
      end

      context 'when deleted' do
        let(:deleted) { true }

        it 'is not visible' do
          refute attachment_data.visible_to?(nil)
        end
      end

      context 'when draft' do
        let(:draft) { true }

        before do
          attachment_data.stubs(:accessible_to?).with(anything).returns(false)
          attachment_data.stubs(:accessible_to?).with(user).returns(accessible)
        end

        context 'and only accessible to specified user' do
          let(:accessible) { true }
          let(:another_user) { build(:user) }

          it 'is visible to user' do
            assert attachment_data.visible_to?(user)
          end

          it 'is not visible to another user' do
            refute attachment_data.visible_to?(another_user)
          end
        end

        context 'and not accessible to user' do
          let(:accessible) { false }

          it 'is not visible to user' do
            refute attachment_data.visible_to?(user)
          end
        end
      end
    end

    context '#visible_attachable_for' do
      let(:attachable) { build(:news_article) }
      let(:significant_attachable) { stub('significant-attachable') }

      before do
        attachment_data.stubs(:visible_to?).with(user).returns(visible)
        attachment_data.stubs(:significant_attachable)
          .returns(significant_attachable)
      end

      context 'when attachment data is not visible' do
        let(:visible) { false }

        it 'returns nil' do
          assert_nil attachment_data.visible_attachable_for(user)
        end
      end

      context 'when attachment data is visible' do
        let(:visible) { true }

        it 'returns attachable for significant attachment' do
          result = attachment_data.visible_attachable_for(user)
          assert_equal significant_attachable, result
        end
      end
    end

    context '#visible_edition_for' do
      let(:visible_attachable) { attachable }

      before do
        attachment_data.stubs(:visible_attachable_for).with(user)
          .returns(visible_attachable)
      end

      context 'when visible attachable is not an edition' do
        let(:attachable) { build(:policy_group) }

        it 'returns nil' do
          assert_nil attachment_data.visible_edition_for(user)
        end
      end

      context 'when visible attachable is an edition' do
        let(:attachable) { build(:edition) }

        it 'returns visible attachable' do
          assert_equal visible_attachable, attachment_data.visible_edition_for(user)
        end
      end
    end

    context '#visible_attachment_for' do
      let(:attachable) { build(:news_article) }
      let(:significant_attachment) { stub('significant-attachment') }

      before do
        attachment_data.stubs(:visible_to?).with(user).returns(visible)
        attachment_data.stubs(:significant_attachment)
          .returns(significant_attachment)
      end

      context 'when attachment data is not visible' do
        let(:visible) { false }

        it 'returns nil' do
          assert_nil attachment_data.visible_attachment_for(user)
        end
      end

      context 'when attachment data is visible' do
        let(:visible) { true }

        it 'returns significant attachment' do
          result = attachment_data.visible_attachment_for(user)
          assert_equal significant_attachment, result
        end
      end
    end
  end
end
