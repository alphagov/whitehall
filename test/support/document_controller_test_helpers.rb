module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_display_attachments_for(document_type)
      test "show displays document attachments" do
        attachment_1 = create(:attachment)
        attachment_2 = create(:attachment)
        document = create("published_#{document_type}", attachments: [attachment_1, attachment_2])

        get :show, id: document.document_identity

        assert_select_object(attachment_1) do
          assert_select '.attachment a', text: attachment_1.filename
        end
        assert_select_object(attachment_2) do
          assert_select '.attachment a', text: attachment_2.filename
        end
      end

      test "show displays PDF attachment metadata" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attachment = create(:attachment, file: greenpaper_pdf)
        document = create("published_#{document_type}", attachments: [attachment])

        get :show, id: document.document_identity

        assert_select_object(attachment) do
          assert_select ".type", "PDF"
          assert_select ".number_of_pages", "1 page"
          assert_select ".size", "3.39 KB"
        end
      end

      test "show displays non-PDF attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, file: csv)
        document = create("published_#{document_type}", attachments: [attachment])

        get :show, id: document.document_identity

        assert_select_object(attachment) do
          assert_select ".type", "CSV"
          refute_select ".number_of_pages"
          assert_select ".size", "121 Bytes"
        end
      end
    end
  end
end