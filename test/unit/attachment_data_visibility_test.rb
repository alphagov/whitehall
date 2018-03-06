require 'test_helper'

class AttachmentDataVisibilityTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { create(:writer) }

  context 'given an attachment' do
    let(:file) { File.open(fixture_path.join('simple.pdf')) }
    let(:attachment) { build(:file_attachment, attachable: attachable, file: file) }
    let(:attachment_data) { attachment.attachment_data }

    before do
      attachable.attachments << attachment
      VirusScanHelpers.simulate_virus_scan(attachment_data.file)
    end

    context 'on a draft edition' do
      let(:edition) { create(:news_article) }
      let(:attachable) { edition }

      it 'is not deleted' do
        refute attachment_data.reload.deleted?
      end

      context 'when attachment is deleted' do
        before do
          attachment.destroy!
        end

        it 'is deleted' do
          assert attachment_data.reload.deleted?
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

          context 'and attachment is deleted' do
            before do
              new_attachment.destroy!
            end

            it 'is not deleted, because available on published edition' do
              refute attachment_data.reload.deleted?
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
      end
    end

    context 'on a draft consultation response' do
      let(:consultation) { create(:consultation) }
      let(:outcome_attributes) { attributes_for(:consultation_outcome) }
      let(:outcome) { consultation.create_outcome!(outcome_attributes) }
      let(:attachable) { outcome }

      it 'is not deleted' do
        refute attachment_data.reload.deleted?
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

          context 'and attachment is deleted' do
            before do
              new_attachment.destroy!
            end

            it 'is not deleted, because available on published edition' do
              refute attachment_data.reload.deleted?
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
      end
    end

    context 'on a policy group' do
      let(:policy_group) { create(:policy_group) }
      let(:attachable) { policy_group }

      it 'is not deleted' do
        refute attachment_data.reload.deleted?
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
  end
end
