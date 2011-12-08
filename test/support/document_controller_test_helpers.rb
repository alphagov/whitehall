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
    
    def should_show_featured_documents_for(document_type)
      document_types = document_type.to_s.pluralize
      test "should ignore unpublished featured #{document_types}" do
        draft_featured_document = create("draft_#{document_type}", featured: true)
        get :index
        refute assigns["featured_#{document_types}"].include?(draft_featured_document)
      end

      test "should ignore published non-featured #{document_types}" do
        published_document = create("published_#{document_type}", featured: false)
        get :index
        refute assigns["featured_#{document_types}"].include?(published_document)
      end
      
      test "should order published featured #{document_types} by published_at" do
        old_document = create("published_#{document_type}", featured: true, published_at: 1.month.ago)
        new_document = create("published_#{document_type}", featured: true, published_at: 1.day.ago)
        get :index
        assert_equal [new_document, old_document], assigns["featured_#{document_types}"]
      end
      
      test "should not display the featured #{document_types} list if there aren't featured #{document_types}" do
        create("published_#{document_type}")
        get :index
        refute_select send("featured_#{document_types}_selector")
      end
      
      test "should display a link to the featured #{document_type}" do
        document = create("published_#{document_type}", featured: true)
        get :index
        assert_select send("featured_#{document_types}_selector") do
          expected_path = send("#{document_type}_path", document.document_identity)
          assert_select "#{record_css_selector(document)} a[href=#{expected_path}]"
        end
      end
      
      test "should display the date the featured #{document_type} was published" do
        published_at = Time.zone.now
        document = create("published_#{document_type}", featured: true, published_at: published_at)
        get :index
        assert_select send("featured_#{document_types}_selector") do
          assert_select "#{record_css_selector(document)} .published_at[title=#{published_at.iso8601}]"
        end
      end
    end
  end
end