module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_display_attachment_metadata_for(document_type)
      test "should display PDF attachment metadata" do
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

      test "should display non-PDF attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, file: csv)
        document = create("published_#{document_type}", attachments: [attachment])

        get :show, id: document.document_identity

        assert_select_object(attachment) do
          assert_select ".type", "CSV"
          assert_select ".number_of_pages", count: 0
          assert_select ".size", "121 Bytes"
        end
      end
    end
  end
end