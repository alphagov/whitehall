module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_display_attachments_for(document_type)
      test "show displays document attachments" do
        attachment_1 = create(:attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'))
        attachment_2 = create(:attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))
        edition = create("published_#{document_type}", attachments: [attachment_1, attachment_2])

        get :show, id: edition.document

        assert_select_object(attachment_1) do
          assert_select '.attachment .attachment_title', text: attachment_1.title
          assert_select '.attachment img[src$=?]', 'thumbnail_greenpaper.pdf.png'
        end
        assert_select_object(attachment_2) do
          assert_select '.attachment .attachment_title', text: attachment_2.title
          assert_select '.attachment img[src$=?]', 'pub-cover.png', message: 'should use default image for non-PDF attachments'
        end
      end

      test "show displays PDF attachment metadata" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attachment = create(:attachment, file: greenpaper_pdf)
        edition = create("published_#{document_type}", attachments: [attachment])

        get :show, id: edition.document

        assert_select_object(attachment) do
          assert_select ".type", /PDF/
          assert_select ".number_of_pages", "1 page"
          assert_select ".size", "3.39 KB"
        end
      end

      test "show displays non-PDF attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, file: csv)
        edition = create("published_#{document_type}", attachments: [attachment])

        get :show, id: edition.document

        assert_select_object(attachment) do
          assert_select ".type", /CSV/
          refute_select ".number_of_pages"
          assert_select ".size", "121 Bytes"
        end
      end
    end

    def should_display_inline_images_for(document_type)
      test "show displays document with inline images" do
        images = [create(:image)]
        edition = create("published_#{document_type}", body: "!!1", images: images)

        get :show, id: edition.document

        assert_select 'article .body figure.image.embedded img'
      end
    end

    def should_display_lead_image_for(document_type)
      test "show displays the image for the #{document_type}" do
        news_article = create("published_#{document_type}", images: [build(:image)])
        get :show, id: news_article.document

        assert_select ".body" do
          assert_select "figure.image.lead img[src='#{news_article.images.first.url}'][alt='#{news_article.images.first.alt_text}']"
        end
      end

      test "show displays the image caption for the #{document_type}" do
        portas_review_jpg = fixture_file_upload('portas-review.jpg')
        edition = create("published_#{document_type}", images: [build(:image, caption: "image caption")])

        get :show, id: edition.document

        assert_select ".body" do
          assert_select "figure.image.lead figcaption", "image caption"
        end
      end

      test "show only displays image if there is one" do
        edition = create("published_#{document_type}", images: [])

        get :show, id: edition.document

        assert_select ".body" do
          refute_select "figure.image.lead"
        end
      end
    end

    def should_not_display_lead_image_for(document_type)
      test "show not show lead image, even if there are associated images" do
        edition = create("published_#{document_type}", images: [build(:image)])

        get :show, id: edition.document

        assert_select ".body" do
          refute_select "figure.image.lead"
        end
      end
    end

    def should_show_related_policies_and_topics_for(document_type)
      test "show displays related published policies" do
        published_policy = create(:published_policy)
        edition = create("published_#{document_type}", related_policies: [published_policy])
        get :show, id: edition.document
        assert_select_object published_policy
      end

      test "show doesn't display related unpublished policies" do
        draft_policy = create(:draft_policy)
        edition = create("published_#{document_type}", related_policies: [draft_policy])
        get :show, id: edition.document
        refute_select_object draft_policy
      end

      test "show infers topics from published policies" do
        topic = create(:topic)
        published_policy = create(:published_policy, topics: [topic])
        edition = create("published_#{document_type}", related_policies: [published_policy])
        get :show, id: edition.document
        assert_select_object topic
      end

      test "show doesn't display duplicate inferred topics" do
        topic = create(:topic)
        published_policy_1 = create(:published_policy, topics: [topic])
        published_policy_2 = create(:published_policy, topics: [topic])
        edition = create("published_#{document_type}", related_policies: [published_policy_1, published_policy_2])
        get :show, id: edition.document
        assert_select_object topic, count: 1
      end

      test "should not display policies unless they are related" do
        unrelated_policy = create(:published_policy)
        edition = create("published_#{document_type}", related_policies: [])
        get :show, id: edition.document
        refute_select_object unrelated_policy
      end

      test "should not display an empty list of related policies" do
        edition = create("published_#{document_type}")
        get :show, id: edition.document
        refute_select "#related-policies"
      end
    end

    def should_show_the_countries_associated_with(document_type)
      test "should display the countries associated with this #{document_type}" do
        first_country = create(:country)
        second_country = create(:country)
        third_country = create(:country)
        edition = create("published_#{document_type}", countries: [first_country, second_country])

        get :show, id: edition.document

        assert_select '#document_countries' do
          assert_select_object first_country
          assert_select_object second_country
          refute_select_object third_country
        end
      end

      test "should not display an empty list of countries" do
        edition = create("published_#{document_type}", countries: [])

        get :show, id: edition.document

        assert_select metadata_nav_selector do
          refute_select '.country'
        end
      end
    end

    def should_show_published_documents_associated_with(model_name, has_many_association, timestamp_key = :published_at)
      singular = has_many_association.to_s.singularize
      test "shows only published #{has_many_association.to_s.humanize.downcase}" do
        published_edition = create("published_#{singular}")
        draft_edition = create("draft_#{singular}")
        model = create(model_name, editions: [published_edition, draft_edition])

        get :show, id: model

        assert_select "##{has_many_association}" do
          assert_select_object(published_edition)
          refute_select_object(draft_edition)
        end
      end

      test "shows only #{has_many_association.to_s.humanize.downcase} associated with #{model_name}" do
        published_edition = create("published_#{singular}")
        another_published_edition = create("published_#{singular}")
        model = create(model_name, editions: [published_edition])

        get :show, id: model

        assert_select "##{has_many_association}" do
          assert_select_object(published_edition)
          refute_select_object(another_published_edition)
        end
      end

      test "shows most recent #{has_many_association.to_s.humanize.downcase} at the top" do
        later_edition = create("published_#{singular}", timestamp_key => 1.hour.ago)
        earlier_edition = create("published_#{singular}", timestamp_key => 2.hours.ago)
        model = create(model_name, editions: [earlier_edition, later_edition])

        get :show, id: model

        assert_equal [later_edition, earlier_edition], assigns(has_many_association)
      end

      test "should not display an empty published #{has_many_association.to_s.humanize.downcase} section" do
        model = create(model_name, editions: [])

        get :show, id: model

        refute_select "##{has_many_association}"
      end
    end


    def should_show_change_notes(document_type)
      should_show_change_notes_on_action(document_type) do |edition|
        get :show, id: edition.document
      end
    end

    def should_show_change_notes_on_action(document_type, &block)
      test "show displays default change note for first edition" do
        first_edition = create("published_#{document_type}", change_note: nil, published_at: 1.month.ago)

        instance_exec(first_edition, &block)

        assert_select ".change_notes li" do
          assert_select ".published_at[title='#{first_edition.published_at.iso8601}']"
          assert_select "p", text: "First published."
        end
      end

      test "show does not display blank change notes in change history" do
        second_edition = create("published_#{document_type}", change_note: nil, minor_change: true, published_at: 1.months.ago)
        document = second_edition.document
        first_edition = create("archived_#{document_type}", change_note: "First effort.", document: document, published_at: 2.months.ago)

        instance_exec(second_edition, &block)

        assert_select ".change_notes li" do
          refute_select ".published_at[title='#{second_edition.published_at.iso8601}']"
          refute_select "p", text: ""
        end
      end

      test "show displays change history in reverse chronological order" do
        editions = []
        editions << create("published_#{document_type}", change_note: "Third go.", published_at: 1.month.ago)
        document = editions.first.document
        editions << create("archived_#{document_type}", change_note: "Second attempt.", document: document, published_at: 2.months.ago)
        editions << create("archived_#{document_type}", change_note: "First effort.", document: document, published_at: 3.months.ago)

        instance_exec(editions.first, &block)

        assert_select ".change_notes li" do |list_items|
          list_items.each_with_index do |list_item, index|
            assert_select list_item, ".published_at[title='#{editions[index].published_at.iso8601}']"
            assert_select list_item, "p", text: editions[index].change_note
          end
        end
      end
    end
  end
end
