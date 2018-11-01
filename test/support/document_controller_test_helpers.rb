module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_display_localised_attachments
      view_test "displays localised file attachments" do
        edition = create("published_#{document_type}", translated_into: %i[en fr])

        attachment = create(:file_attachment, locale: nil, attachable: edition)
        english_attachment = create(:file_attachment, locale: :en, attachable: edition)
        french_attachment = create(:file_attachment, locale: :fr, attachable: edition)

        get :show, params: { id: edition.document }
        assert_select_object(attachment)
        assert_select_object(english_attachment)
        refute_select_object(french_attachment)

        get :show, params: { id: edition.document, locale: :fr }
        assert_select_object(attachment)
        refute_select_object(english_attachment)
        assert_select_object(french_attachment)
      end

      view_test 'displays localised HTML attachments' do
        edition = create("published_#{document_type}", translated_into: %i[en fr])

        attachment = create(:html_attachment, locale: nil, attachable: edition)
        english_attachment = create(:html_attachment, locale: :en, attachable: edition)
        french_attachment = create(:html_attachment, locale: :fr, attachable: edition)

        get :show, params: { id: edition.document }
        assert_select_object(attachment)
        assert_select_object(english_attachment)
        refute_select_object(french_attachment)

        get :show, params: { id: edition.document, locale: :fr }
        assert_select_object(attachment)
        refute_select_object(english_attachment)
        assert_select_object(french_attachment)
      end
    end

    def should_display_attachments_for(document_type)
      view_test "show displays file attachments" do
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1\n\n!@2", attachments: [
          attachment_1 = build(:file_attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf')),
          attachment_2 = build(:file_attachment, file: fixture_file_upload('sample.rtf', 'text/rtf'))
        ])

        get :show, params: { id: edition.document }

        assert_select_object(attachment_1) do
          assert_select '.title', text: attachment_1.title
          assert_select 'img[src$=?]', 'thumbnail_greenpaper.pdf.png'
        end
        assert_select_object(attachment_2) do
          assert_select '.title', text: attachment_2.title
          assert_select 'img[src$=?]', 'pub-cover.png', message: 'should use default image for non-PDF attachments'
        end
      end

      view_test 'show displays HTML attachments' do
        edition = create("published_#{document_type}", :with_alternative_format_provider, :with_html_attachment, body: '!@1')
        attachment = edition.attachments.first
        get :show, params: { id: edition.document }
        assert_select_object(attachment) do
          assert_select '.title', text: attachment.title
          assert_select 'img[src$=?]', 'pub-cover-html.png', message: 'should use HTML thumbnail for HTML attachments'
        end
      end

      view_test "show information about accessibility" do
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1\n\n!@2", attachments: [
          attachment_1 = build(:file_attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'), accessible: true),
          attachment_2 = build(:file_attachment, file: fixture_file_upload('sample.rtf', 'text/rtf'))
        ])

        get :show, params: { id: edition.document }

        assert_select_object(attachment_1) do
          refute_select '.accessibility-warning'
          refute_select ".title a[aria-describedby='attachment-#{attachment_1.id}-accessibility-help']"
        end
        assert_select_object(attachment_2) do
          assert_select ".title a[aria-describedby='attachment-#{attachment_2.id}-accessibility-help']"
          assert_select '.accessibility-warning'
        end
      end

      view_test "show alternative format contact email if given" do
        organisation = create(:organisation, alternative_format_contact_email: "alternative@example.com")
        edition = create("published_#{document_type}", body: "!@1", attachments: [
          attachment_1 = build(:file_attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'), accessible: false)
        ], alternative_format_provider: organisation)

        get :show, params: { id: edition.document }

        assert_select_object(attachment_1) do
          assert_select '.accessibility-warning' do
            assert_select 'a[href^="mailto:alternative@example.com"]'
          end
        end
      end

      view_test "show displays PDF attachment metadata" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1", attachments: [
          attachment = build(:file_attachment, file: greenpaper_pdf)
        ])

        get :show, params: { id: edition.document }

        assert_select_object(attachment) do
          assert_select ".type", /PDF/
          assert_select ".page-length", "1 page"
          assert_select ".file-size", "3.39KB"
        end
      end

      view_test "show displays non-PDF attachment metadata" do
        csv = fixture_file_upload('sample.rtf', 'text/rtf')
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1", attachments: [
          attachment = build(:file_attachment, file: csv)
        ])

        get :show, params: { id: edition.document }

        assert_select_object(attachment) do
          assert_select ".type", /RTF/
          refute_select ".page-length"
          assert_select ".file-size", "288Bytes"
        end
      end
    end

    def should_display_inline_images_for(document_type)
      view_test "show displays #{document_type} with inline images" do
        images = [create(:image), create(:image)]
        edition = create("published_#{document_type}", body: "!!2", images: images)

        get :show, params: { id: edition.document }

        assert_select 'article figure.image.embedded img'
      end
    end

    def should_show_related_policies_for(document_type)
      view_test "show displays related published policies for #{document_type}" do
        edition = create("published_#{document_type}", policy_content_ids: [policy_1['content_id'], policy_2['content_id']])
        get :show, params: { id: edition.document }
        assert_select '.meta a', text: "Policy 1"
      end

      view_test "should not display an empty list of related policies for #{document_type}" do
        edition = create("published_#{document_type}", policy_content_ids: [])
        get :show, params: { id: edition.document }
        refute_select "#related-policies"
      end

      view_test "should render related policies on #{document_type} pages" do
        edition = create("published_#{document_type}", policy_content_ids: [policy_1["content_id"]])
        get :show, params: { id: edition.document }
        assert_select ".meta a", text: policy_1["title"]
      end

      view_test "shows no policies if publishing api is unavailable" do
        edition = create("published_#{document_type}", policy_content_ids: [policy_1["content_id"]])
        publishing_api_isnt_available
        get :show, params: { id: edition.document }
        refute_select ".meta a", text: policy_1["title"]
      end
    end

    def should_show_the_world_locations_associated_with(document_type)
      view_test "should display the world locations associated with this #{document_type}" do
        first_location = create(:world_location)
        second_location = create(:world_location)
        third_location = create(:international_delegation)
        edition = create("published_#{document_type}", world_locations: [first_location, second_location])

        get :show, params: { id: edition.document }

        assert_select "a", text: first_location.name
        assert_select "a", text: second_location.name
        assert_select "a", text: third_location.name, count: 0
      end
    end

    def should_show_published_documents_associated_with(model_name, has_many_association, timestamp_key = :first_published_at)
      singular = has_many_association.to_s.singularize
      view_test "shows only published #{has_many_association.to_s.humanize.downcase}" do
        published_edition = create("published_#{singular}")
        draft_edition = create("draft_#{singular}")
        model = create(model_name, editions: [published_edition, draft_edition])

        get :show, params: { id: model }

        assert_select "##{has_many_association.to_s.tr('_', '-')}" do
          assert_select_object(published_edition)
          refute_select_object(draft_edition)
        end
      end

      view_test "shows only #{has_many_association.to_s.humanize.downcase} associated with #{model_name}" do
        published_edition = create("published_#{singular}")
        another_published_edition = create("published_#{singular}")
        model = create(model_name, editions: [published_edition])

        get :show, params: { id: model }

        assert_select "##{has_many_association.to_s.tr('_', '-')}" do
          assert_select_object(published_edition)
          refute_select_object(another_published_edition)
        end
      end

      test "shows most recent #{has_many_association.to_s.humanize.downcase} at the top" do
        later_edition = create("published_#{singular}", timestamp_key => 1.hour.ago)
        earlier_edition = create("published_#{singular}", timestamp_key => 2.hours.ago)
        model = create(model_name, editions: [earlier_edition, later_edition])

        get :show, params: { id: model }

        assert_equal [later_edition, earlier_edition], assigns(has_many_association).object
      end

      view_test "should not display an empty published #{has_many_association.to_s.humanize.downcase} section" do
        model = create(model_name, editions: [])

        get :show, params: { id: model }

        refute_select "##{has_many_association.to_s.tr('_', '-')}"
      end
    end

    def should_set_expiry_headers(document_type)
      test "#{document_type} should set an expiry of 30 minutes" do
        edition = create("published_#{document_type}")
        get :show, params: { id: edition.document }
        Whitehall.stubs(:default_cache_max_age).returns(30.minutes)
        assert_equal 'max-age=1800, public', response.headers['Cache-Control']
      end
    end

    def should_be_previewable(document_type)
      test "#{document_type} preview should be visible for logged in users" do
        first_edition = create("published_#{document_type}")
        document = first_edition.document
        draft_edition = create("draft_#{document_type}",
                               document: document,
                               body: "Draft information",
                               access_limited: false)

        login_as create(:departmental_editor)
        get :show, params: { id: document.id, preview: draft_edition.id }
        assert_response 200
        assert_cache_control 'no-cache'
      end

      test "#{document_type} preview should be hidden from public" do
        first_edition = create("published_#{document_type}")
        document = first_edition.document
        draft_edition = create("draft_#{document_type}",
                               document: document,
                               body: "Draft information",
                               access_limited: false)

        get :show, params: { id: document.id, preview: draft_edition.id }
        assert_response 404
      end

      test "access limited #{document_type} preview should be visible for authorised users" do
        draft = create(document_type, :published, access_limited: true)

        login_as(create(:departmental_editor, organisation: draft.organisations.first))
        get :show, params: { id: draft.document.id, preview: draft.id }

        assert_response 200
        assert_cache_control 'no-cache'
      end

      test "access limited #{document_type} preview should be hidden for unauthorised users" do
        draft = create(document_type, :published, access_limited: true)

        login_as(create(:departmental_editor))
        get :show, params: { id: draft.document.id, preview: draft.id }

        assert_response 404
      end
    end

    def should_show_inapplicable_nations(document_type)
      view_test "show displays inapplicable nations for #{document_type}" do
        published_document = create("published_#{document_type}")
        northern_ireland_inapplicability = published_document.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
        scotland_inapplicability = published_document.nation_inapplicabilities.create!(nation: Nation.scotland)

        get :show, params: { id: published_document.document }

        assert_select inapplicable_nations_selector, "England and Wales (see #{published_document.format_name} for Northern Ireland)" do
          assert_select_object northern_ireland_inapplicability do
            assert_select "a[href='http://northern-ireland.com/']"
          end
          refute_select_object scotland_inapplicability
        end
      end
    end

    def should_paginate(edition_type, options = {})
      include DocumentFilterHelpers
      options.reverse_merge!(timestamp_key: :first_published_at)

      test "index should only fetch a certain number of #{edition_type.to_s.pluralize} by default" do
        Sidekiq::Testing.inline! do
          documents = (1..6).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}-index-default", options[:timestamp_key] => i.days.ago) }
          documents.sort_by!(&options[:sort_by]) if options[:sort_by]

          with_number_of_documents_per_page(3) do
            get :index
          end

          (0..2).to_a.each { |i| assert_filtered_documents_include documents[i] }
          (3..5).to_a.each { |i| refute_filtered_documents_include documents[i] }
        end
      end

      test "index should fetch the correct page for #{edition_type}" do
        Sidekiq::Testing.inline! do
          documents = (1..6).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}-window-pagination", options[:timestamp_key] => i.days.ago) }
          documents.sort_by!(&options[:sort_by]) if options[:sort_by]

          with_number_of_documents_per_page(3) do
            get :index, params: { page: 2 }
          end

          (0..2).to_a.each { |i| refute_filtered_documents_include documents[i] }
          (3..5).to_a.each { |i| assert_filtered_documents_include documents[i] }
        end
      end

      view_test "show more button should not appear by default for #{edition_type}" do
        (1..3).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

        with_number_of_documents_per_page(3) do
          get :index
        end

        refute_select "#show-more-documents"
      end

      view_test "show more button should appear when there are more records for #{edition_type}" do
        Sidekiq::Testing.inline! do
          (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }
        end

        with_number_of_documents_per_page(3) do
          get :index
        end

        assert_select "#show-more-documents"
      end

      view_test "should show previous page link when not on the first page for #{edition_type}" do
        Sidekiq::Testing.inline! do
          (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }
        end

        with_number_of_documents_per_page(3) do
          get :index, params: { page: 2 }
        end

        assert_select "#show-more-documents" do
          assert_select ".previous"
          refute_select ".next"
        end
      end

      view_test "should show progress helpers in pagination links for #{edition_type}" do
        Sidekiq::Testing.inline! do
          (1..7).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }
        end

        with_number_of_documents_per_page(3) do
          get :index, params: { page: 2 }
        end

        assert_select "#show-more-documents" do
          assert_select ".previous span", text: "1 of 3"
          assert_select ".next span", text: "3 of 3"
        end
      end
    end

    def should_return_json_suitable_for_the_document_filter(document_type)
      include DocumentFilterHelpers
      announcement = %i(news_article speech).include?(document_type)
      view_test "index requested as JSON includes a count of #{document_type}" do
        rummager = stub
        with_stubbed_rummager(rummager, announcement) do
          if announcement
            rummager.expects(:search).returns('results' =>
              [{ 'format' => document_type.to_s }])
          else
            rummager.expects(:advanced_search).returns('results' =>
              [{ 'format' => document_type.to_s,
                 'public_timestamp' => Time.zone.now.to_s }])
          end
          get :index, format: :json

          assert_equal 1, ActiveSupport::JSON.decode(response.body)["count"]
        end
      end

      view_test "index requested as JSON includes the total pages of #{document_type}" do
        rummager = stub
        with_stubbed_rummager(rummager, announcement) do
          if announcement
            rummager.expects(:search).returns('results' => (0..4).map { |n| { 'format' => document_type.to_s, 'content_id' => n } })
          else
            rummager.expects(:advanced_search).returns('results' =>
                                                (0..4).map { { 'format' => document_type.to_s, 'public_timestamp' => Time.zone.now.to_s } })
          end
          with_number_of_documents_per_page(3) do
            get :index, format: :json
          end

          assert_equal 2, ActiveSupport::JSON.decode(response.body)["total_pages"]
        end
      end

      view_test "index requested as JSON includes the current page of #{document_type}" do
        rummager = stub
        with_stubbed_rummager(rummager) do
          if announcement
            rummager.expects(:search).returns('results' => [{ 'format' => document_type.to_s, 'id' => 1 }])
          else
            rummager.expects(:advanced_search).returns('results' =>
              [{ 'format' => document_type.to_s, 'id' => 1, 'public_timestamp' => Time.zone.now.to_s }])
          end

          get :index, format: :json
          assert_equal 1, ActiveSupport::JSON.decode(response.body)["current_page"]
        end
      end
    end

    def should_set_meta_description_for(document_type)
      test "#{document_type} should set a meaningful meta description" do
        edition = create("published_#{document_type}", summary: "My **first** #{document_type}")

        get :show, params: { id: edition.document }

        assert_equal "My first #{document_type}", assigns(:meta_description)
      end
    end

    def should_set_slimmer_analytics_headers_for(document_type)
      test "#{document_type} should set Google Analytics organisation headers" do
        organisation = create(:organisation)
        lead_organisation = create(:organisation, acronym: "ABC")
        edition = create("published_#{document_type}", supporting_organisations: [organisation], lead_organisations: [lead_organisation])
        get :show, params: { id: edition.document }

        assert_equal "<#{lead_organisation.analytics_identifier}><#{organisation.analytics_identifier}>", response.headers["X-Slimmer-Organisations"]
        assert_equal lead_organisation.acronym.downcase, response.headers["X-Slimmer-Page-Owner"]
      end
    end

    def should_set_the_article_id_for_the_edition_for(document_type)
      view_test "#{document_type} should set the article ID to the edition type/ID" do
        edition = create("published_#{document_type}")
        get :show, params: { id: edition.document }

        assert_select "article##{document_type}_#{edition.id}"
      end
    end

    def should_show_share_links_for(document_type)
      view_test "#{document_type} should show share links" do
        edition = create("published_#{document_type}")
        get :show, params: { id: edition.document }
        assert_select ".document-share-links"
      end
    end

    def should_not_show_share_links_for(document_type)
      view_test "#{document_type} should not show share links" do
        edition = create("published_#{document_type}")
        get :show, params: { id: edition.document }
        refute_select ".document-share-links"
      end
    end
  end

private

  def assert_filtered_documents_include(edition)
    assert_includes assigns(:filter).documents.map(&:id), edition.id
  end

  def refute_filtered_documents_include(edition)
    refute_includes assigns(:filter).documents.map(&:id), edition.id
  end

  def controller_attributes_for(edition_type, attributes = {})
    if edition_type.to_s.classify.constantize.new.can_be_related_to_organisations?
      attributes = attributes.merge(
        lead_organisation_ids: [(Organisation.first || create(:organisation)).id]
      )
    end

    if edition_type.to_s.classify.constantize.new.can_be_associated_with_topics?
      attributes = attributes.merge(
        topic_ids: [(Topic.first || create(:topic)).id]
      )
    end

    attributes_for(edition_type, attributes).except(:attachments)
  end

  def document_type
    controller.send(:document_class).name.underscore
  end
end
