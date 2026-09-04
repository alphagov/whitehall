require "test_helper"

module ServiceListeners
  class AttachmentUpdaterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    describe ".call" do
      it "re-syncs a consultation's response form data asset metadata" do
        consultation = create(:draft_consultation)
        response_form = build(:consultation_response_form, consultation_participation: nil)
        create(:consultation_participation, consultation:, consultation_response_form: response_form)
        consultation.reload

        response_form_data = response_form.consultation_response_form_data

        AssetManagerAttachmentMetadataJob.expects(:perform_async).with(response_form_data.id, "ConsultationResponseFormData")

        ServiceListeners::AttachmentUpdater.call(attachable: consultation)
      end

      it "re-syncs a call for evidence's response form data asset metadata" do
        call_for_evidence = create(:draft_call_for_evidence)
        response_form = build(:call_for_evidence_response_form, call_for_evidence_participation: nil)
        create(:call_for_evidence_participation, call_for_evidence:, call_for_evidence_response_form: response_form)
        call_for_evidence.reload

        response_form_data = response_form.call_for_evidence_response_form_data

        AssetManagerAttachmentMetadataJob.expects(:perform_async).with(response_form_data.id, "CallForEvidenceResponseFormData")

        ServiceListeners::AttachmentUpdater.call(attachable: call_for_evidence)
      end

      it "does nothing for editions with no response form data" do
        consultation = create(:draft_consultation)

        AssetManagerAttachmentMetadataJob.expects(:perform_async).never

        ServiceListeners::AttachmentUpdater.call(attachable: consultation)
      end
    end
  end
end
