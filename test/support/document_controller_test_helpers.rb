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
          assert_select '.attachment .attachment_title', text: attachment_1.title
        end
        assert_select_object(attachment_2) do
          assert_select '.attachment .attachment_title', text: attachment_2.title
        end
      end

      test "show displays PDF attachment metadata" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attachment = create(:attachment, file: greenpaper_pdf)
        document = create("published_#{document_type}", attachments: [attachment])

        get :show, id: document.document_identity

        assert_select_object(attachment) do
          assert_select ".type", /PDF/
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
          assert_select ".type", /CSV/
          refute_select ".number_of_pages"
          assert_select ".size", "121 Bytes"
        end
      end
    end

    def should_display_inline_images_for(document_type)
      test "show displays document with inline images" do
        images = [create(:image)]
        document = create("published_#{document_type}", body: "!!1", images: images)

        get :show, id: document.document_identity

        assert_select 'article .body figure.image.embedded img'
      end
    end

    def should_display_lead_image_for(document_type)
      test "show displays the image for the #{document_type}" do
        news_article = create("published_#{document_type}", images: [build(:image)])
        get :show, id: news_article.document_identity

        assert_select ".document_view" do
          assert_select "figure.image.lead img[src='#{news_article.images.first.url}'][alt='#{news_article.images.first.alt_text}']"
        end
      end

      test "show displays the image caption for the #{document_type}" do
        portas_review_jpg = fixture_file_upload('portas-review.jpg')
        document = create("published_#{document_type}", images: [build(:image, caption: "image caption")])

        get :show, id: document.document_identity

        assert_select ".document_view" do
          assert_select "figure.image.lead figcaption", "image caption"
        end
      end

      test "show only displays image if there is one" do
        document = create("published_#{document_type}", images: [])

        get :show, id: document.document_identity

        assert_select ".document_view" do
          refute_select "figure.image.lead"
        end
      end
    end

    def should_not_display_lead_image_for(document_type)
      test "show not show lead image, even if there are associated images" do
        document = create("published_#{document_type}", images: [build(:image)])

        get :show, id: document.document_identity

        assert_select ".document_view" do
          refute_select "figure.image.lead"
        end
      end
    end

    def should_show_featured_documents_for(document_type)
      document_types = document_type.to_s.pluralize
      test "should ignore unpublished featured #{document_types}" do
        draft_featured_document = create("draft_#{document_type}") do |document|
          document.feature
        end
        get :index
        refute assigns["featured_#{document_types}"].include?(draft_featured_document)
      end

      test "should ignore published non-featured #{document_types}" do
        published_document = create("published_#{document_type}")
        get :index
        refute assigns["featured_#{document_types}"].include?(published_document)
      end

      test "should order published featured #{document_types} by published_at" do
        old_document = create("featured_#{document_type}", published_at: 1.month.ago)
        new_document = create("featured_#{document_type}", published_at: 1.day.ago)
        get :index
        assert_equal [new_document, old_document], assigns["featured_#{document_types}"]
      end

      test "should not display the featured #{document_types} list if there aren't featured #{document_types}" do
        create("published_#{document_type}")
        get :index
        refute_select send("featured_#{document_types}_selector")
      end

      test "should display a link to the featured #{document_type}" do
        document = create("featured_#{document_type}")
        get :index
        assert_select send("featured_#{document_types}_selector") do
          expected_path = send("#{document_type}_path", document.document_identity)
          assert_select "#{record_css_selector(document)} a[href=#{expected_path}]"
        end
      end
    end

    def should_show_three_featured_news_articles
      should_show_featured_documents_for :news_article
      test "index highlights three featured news articles" do
        articles = 3.times.map do |n|
          create(:featured_news_article, published_at: n.days.ago)
        end

        get :index

        assert_equal articles.take(3), assigns[:featured_news_articles]
        assert_select '#featured-news-articles' do
          articles.take(3).each do |article|
            assert_select_object article
          end
        end
      end

      test "index highlights three featured news articles in order of first publication" do
        articles = 3.times.map do |n|
          create(:featured_news_article, published_at: n.days.ago)
        end

        editor = create(:departmental_editor)
        articles.push(updated_article = articles.pop.create_draft(editor))
        updated_article.change_note = "change-note"
        updated_article.publish_as(editor, force: true)

        get :index

        assert_equal articles.take(3), assigns[:featured_news_articles]
      end

      test "index should display an image for a featured news article if it has one" do
        lead_image = create(:image)
        document = create(:featured_news_article, images: [lead_image])
        get :index
        assert_select featured_news_articles_selector do
          assert_select_object document do
            assert_select ".img img[src='#{lead_image.url}']"
          end
        end
      end

      test "index should not display an image for a featured news article if it does not have one" do
        document = create(:featured_news_article)
        get :index
        assert_select featured_news_articles_selector do
          assert_select_object document do
            refute_select ".img img"
          end
        end
      end
    end

    def should_show_related_policies_and_policy_topics_for(document_type)
      test "show displays related published policies" do
        published_policy = create(:published_policy)
        document = create("published_#{document_type}", related_policies: [published_policy])
        get :show, id: document.document_identity
        assert_select_object published_policy
      end

      test "show doesn't display related unpublished policies" do
        draft_policy = create(:draft_policy)
        document = create("published_#{document_type}", related_policies: [draft_policy])
        get :show, id: document.document_identity
        refute_select_object draft_policy
      end

      test "show infers policy topics from published policies" do
        policy_topic = create(:policy_topic)
        published_policy = create(:published_policy, policy_topics: [policy_topic])
        document = create("published_#{document_type}", related_policies: [published_policy])
        get :show, id: document.document_identity
        assert_select_object policy_topic
      end

      test "show doesn't display duplicate inferred policy topics" do
        policy_topic = create(:policy_topic)
        published_policy_1 = create(:published_policy, policy_topics: [policy_topic])
        published_policy_2 = create(:published_policy, policy_topics: [policy_topic])
        document = create("published_#{document_type}", related_policies: [published_policy_1, published_policy_2])
        get :show, id: document.document_identity
        assert_select_object policy_topic, count: 1
      end

      test "should not display policies unless they are related" do
        unrelated_policy = create(:published_policy)
        document = create("published_#{document_type}", related_policies: [])
        get :show, id: document.document_identity
        refute_select_object unrelated_policy
      end

      test "should not display an empty list of related policies" do
        document = create("published_#{document_type}")
        get :show, id: document.document_identity
        refute_select "#related-policies"
      end
    end

    def should_show_the_countries_associated_with(document_type)
      test "should display the countries associated with this #{document_type}" do
        first_country = create(:country)
        second_country = create(:country)
        third_country = create(:country)
        document = create("published_#{document_type}", countries: [first_country, second_country])

        get :show, id: document.document_identity

        assert_select '#document_countries' do
          assert_select_object first_country
          assert_select_object second_country
          refute_select_object third_country
        end
      end

      test "should not display an empty list of countries" do
        document = create("published_#{document_type}", countries: [])

        get :show, id: document.document_identity

        assert_select metadata_nav_selector do
          refute_select '.country'
        end
      end
    end

    def should_show_published_documents_associated_with(model_name, has_many_association, timestamp_key = :published_at)
      singular = has_many_association.to_s.singularize
      test "shows only published #{has_many_association.to_s.humanize.downcase}" do
        published_document = create("published_#{singular}")
        draft_document = create("draft_#{singular}")
        model = create(model_name, documents: [published_document, draft_document])

        get :show, id: model

        assert_select "##{has_many_association}" do
          assert_select_object(published_document)
          refute_select_object(draft_document)
        end
      end

      test "shows only #{has_many_association.to_s.humanize.downcase} associated with #{model_name}" do
        published_document = create("published_#{singular}")
        another_published_document = create("published_#{singular}")
        model = create(model_name, documents: [published_document])

        get :show, id: model

        assert_select "##{has_many_association}" do
          assert_select_object(published_document)
          refute_select_object(another_published_document)
        end
      end

      test "shows most recent #{has_many_association.to_s.humanize.downcase} at the top" do
        later_document = create("published_#{singular}", timestamp_key => 1.hour.ago)
        earlier_document = create("published_#{singular}", timestamp_key => 2.hours.ago)
        model = create(model_name, documents: [earlier_document, later_document])

        get :show, id: model

        assert_equal [later_document, earlier_document], assigns[has_many_association]
      end

      test "should not display an empty published #{has_many_association.to_s.humanize.downcase} section" do
        model = create(model_name, documents: [])

        get :show, id: model

        refute_select "##{has_many_association}"
      end
    end
  end
end