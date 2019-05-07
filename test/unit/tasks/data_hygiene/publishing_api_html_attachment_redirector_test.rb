require "test_helper"

class PublishingApiHtmlAttachmentRedirectorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let!(:document)               { create(:document) }
  let!(:attachment)             { create(:html_attachment, locale: 'en') }
  let!(:superseded_edition)     { create(:superseded_edition) }
  let!(:edition)                {
    create(
      :unpublished_edition,
      state: "withdrawn",
      document: document,
      attachments: [attachment]
)
  }
  let!(:redirection)            { "www.example.com/attachment_path" }
  let(:queried_document_id)     {}

  def call_html_attachment_redirector
    DataHygiene::PublishingApiHtmlAttachmentRedirector.call(
      queried_document_id,
      redirection,
      dry_run: dry_run
    )
  end

  context "during a dry run" do
    let(:dry_run) { true }
    let(:queried_document_id) { document.content_id }

    it "does not send the redirection to the Publishing API" do
      PublishingApiRedirectWorker.any_instance.expects(:perform).never
      call_html_attachment_redirector
    end

    it "reports the html attachment that would have changed" do
      output = "Would have redirected: #{[attachment.slug]}\nto #{redirection}\n"
      assert_output(output) { call_html_attachment_redirector }
    end
  end

  context "during a real run" do
    let(:dry_run) { false }

    context "the last edition has not been unpublished" do
      let!(:published_document)   { create(:document) }
      let!(:published_edition)    { create(:edition, document: published_document, attachments: []) }
      let(:queried_document_id)   { published_document.content_id }

      it "raises an exception" do
        assert_raises DataHygiene::EditionNotUnpublished do
          call_html_attachment_redirector
        end
      end
    end

    context "the last edition has no HTML attachments" do
      let!(:unattached_document)   { create(:document) }
      let!(:unattached_edition)    { create(:unpublished_edition, document: unattached_document, attachments: []) }
      let(:queried_document_id)    { unattached_document.content_id }

      it "raises an exception" do
        assert_raises DataHygiene::HTMLAttachmentsNotFound do
          call_html_attachment_redirector
        end
      end
    end

    context "the edition has been unpublished" do
      let(:queried_document_id)   { document.content_id }

      it "calls the redirect worker with the HTML attachments to redirect" do
        PublishingApiRedirectWorker
          .any_instance
          .expects(:perform)
          .with(attachment.content_id, redirection, attachment.locale)

        call_html_attachment_redirector
      end

      it "reports the redirections sent to the Publishing API" do
        output = "Redirected: #{[attachment.slug]}\nto #{redirection}\n"
        assert_output(output) { call_html_attachment_redirector }
      end
    end
  end
end
