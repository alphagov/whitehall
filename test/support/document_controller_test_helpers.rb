module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_display_attachments_for(document_type)
      view_test "show displays document attachments" do
        attachment_1 = create(:attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'))
        attachment_2 = create(:attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1\n\n!@2", attachments: [attachment_1, attachment_2])

        get :show, id: edition.document

        assert_select_object(attachment_1) do
          assert_select '.title', text: attachment_1.title
          assert_select 'img[src$=?]', 'thumbnail_greenpaper.pdf.png'
        end
        assert_select_object(attachment_2) do
          assert_select '.title', text: attachment_2.title
          assert_select 'img[src$=?]', 'pub-cover.png', message: 'should use default image for non-PDF attachments'
        end
      end

      view_test "show information about accessibility" do
        attachment_1 = create(:attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'), accessible: true)
        attachment_2 = create(:attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))

        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1\n\n!@2", attachments: [attachment_1, attachment_2])

        get :show, id: edition.document

        assert_select_object(attachment_1) do
          refute_select '.accessibility-warning'
          refute_select "a.thumbnail[aria-describedby='attachment-#{attachment_1.id}-accessibility-help']"
        end
        assert_select_object(attachment_2) do
          assert_select "a.thumbnail[aria-describedby='attachment-#{attachment_2.id}-accessibility-help']"
          assert_select '.accessibility-warning'
        end
      end

      view_test "show alternative format contact email if given" do
        attachment_1 = create(:attachment, file: fixture_file_upload('greenpaper.pdf', 'application/pdf'), accessible: false)

        organisation = create(:organisation, alternative_format_contact_email: "alternative@example.com")
        edition = create("published_#{document_type}", body: "!@1", attachments: [attachment_1], alternative_format_provider: organisation)

        get :show, id: edition.document

        assert_select_object(attachment_1) do
          assert_select '.accessibility-warning' do
            assert_select 'a[href^="mailto:alternative@example.com"]'
          end
        end
      end

      view_test "show displays PDF attachment metadata" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attachment = create(:attachment, file: greenpaper_pdf)
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1", attachments: [attachment])

        get :show, id: edition.document

        assert_select_object(attachment) do
          assert_select ".type", /PDF/
          assert_select ".page-length", "1 page"
          assert_select ".file-size", "3.39KB"
        end
      end

      view_test "show displays non-PDF attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, file: csv)
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1", attachments: [attachment])

        get :show, id: edition.document

        assert_select_object(attachment) do
          assert_select ".type", /CSV/
          refute_select ".page-length"
          assert_select ".file-size", "121Bytes"
        end
      end
    end

    def should_display_inline_images_for(document_type)
      view_test "show displays #{document_type} with inline images" do
        images = [create(:image), create(:image)]
        edition = create("published_#{document_type}", body: "!!2", images: images)

        get :show, id: edition.document

        assert_select 'article .body figure.image.embedded img'
      end
    end

    def should_show_related_policies_for(document_type)
      view_test "show displays related published policies for #{document_type}" do
        published_policy = create(:published_policy)
        edition = create("published_#{document_type}", related_editions: [published_policy])
        get :show, id: edition.document
        assert_select_object published_policy
      end

      view_test "show doesn't display related unpublished policies for #{document_type}" do
        draft_policy = create(:draft_policy)
        edition = create("published_#{document_type}", related_editions: [draft_policy])
        get :show, id: edition.document
        refute_select_object draft_policy
      end

      view_test "should not display policies unless they are related for #{document_type}" do
        unrelated_policy = create(:published_policy)
        edition = create("published_#{document_type}", related_editions: [])
        get :show, id: edition.document
        refute_select_object unrelated_policy
      end

      view_test "should not display an empty list of related policies for #{document_type}" do
        edition = create("published_#{document_type}")
        get :show, id: edition.document
        refute_select "#related-policies"
      end
    end

    def should_show_related_policies_and_topics_for(document_type)
      should_show_related_policies_for document_type

      view_test "show infers topics from published policies for #{document_type}" do
        topic = create(:topic)
        published_policy = create(:published_policy, topics: [topic])
        edition = create("published_#{document_type}", related_editions: [published_policy])
        get :show, id: edition.document
        assert_select_object topic
      end

      view_test "show doesn't display duplicate inferred topics for #{document_type}" do
        topic = create(:topic)
        published_policy_1 = create(:published_policy, topics: [topic])
        published_policy_2 = create(:published_policy, topics: [topic])
        edition = create("published_#{document_type}", related_editions: [published_policy_1, published_policy_2])
        get :show, id: edition.document
        assert_select_object topic, count: 1
      end
    end

    def should_show_the_world_locations_associated_with(document_type)
      view_test "should display the world locations associated with this #{document_type}" do
        first_location = create(:world_location)
        second_location = create(:world_location)
        third_location = create(:international_delegation)
        edition = create("published_#{document_type}", world_locations: [first_location, second_location])

        get :show, id: edition.document

        assert_select '.document-world-locations' do
          assert_select "##{dom_id(first_location)}", text: first_location.name
          assert_select "##{dom_id(second_location)}", text: second_location.name
          assert_select "##{dom_id(third_location)}", count: 0
        end
      end

      view_test "should not display an empty list of world locations for #{document_type}" do
        edition = create("published_#{document_type}", world_locations: [])

        get :show, id: edition.document

        assert_select metadata_nav_selector do
          refute_select '.world-location'
        end
      end
    end

    def should_show_published_documents_associated_with(model_name, has_many_association, timestamp_key = :first_published_at)
      singular = has_many_association.to_s.singularize
      view_test "shows only published #{has_many_association.to_s.humanize.downcase}" do
        published_edition = create("published_#{singular}")
        draft_edition = create("draft_#{singular}")
        model = create(model_name, editions: [published_edition, draft_edition])

        get :show, id: model

        assert_select "##{has_many_association.to_s.gsub('_', '-')}" do
          assert_select_object(published_edition)
          refute_select_object(draft_edition)
        end
      end

      view_test "shows only #{has_many_association.to_s.humanize.downcase} associated with #{model_name}" do
        published_edition = create("published_#{singular}")
        another_published_edition = create("published_#{singular}")
        model = create(model_name, editions: [published_edition])

        get :show, id: model

        assert_select "##{has_many_association.to_s.gsub('_', '-')}" do
          assert_select_object(published_edition)
          refute_select_object(another_published_edition)
        end
      end

      test "shows most recent #{has_many_association.to_s.humanize.downcase} at the top" do
        later_edition = create("published_#{singular}", timestamp_key => 1.hour.ago)
        earlier_edition = create("published_#{singular}", timestamp_key => 2.hours.ago)
        model = create(model_name, editions: [earlier_edition, later_edition])

        get :show, id: model

        assert_equal [later_edition, earlier_edition], assigns(has_many_association).object
      end

      view_test "should not display an empty published #{has_many_association.to_s.humanize.downcase} section" do
        model = create(model_name, editions: [])

        get :show, id: model

        refute_select "##{has_many_association.to_s.gsub('_', '-')}"
      end
    end

    def should_set_expiry_headers(document_type)
      test "#{document_type} should set an expiry of 30 minutes" do
        edition = create("published_#{document_type}")
        get :show, id: edition.document
        assert_equal 'max-age=1800, public', response.headers['Cache-Control']
      end
    end

    def should_be_previewable(document_type)
      test "#{document_type} preview should be visible for logged in users" do
        first_edition = create("published_#{document_type}")
        document = first_edition.document
        draft_edition = create("draft_#{document_type}",
                               document: document,
                               body: "Draft information")

        login_as create(:departmental_editor)
        get :show, id: document.id, preview: draft_edition.id
        assert_response 200
      end

      test "#{document_type} preview should be hidden from public" do
        first_edition = create("published_#{document_type}")
        document = first_edition.document
        draft_edition = create("draft_#{document_type}",
                               document: document,
                               body: "Draft information")

        get :show, id: document.id, preview: draft_edition.id
        assert_response 404
      end
    end

    def should_show_inapplicable_nations(document_type)
      view_test "show displays inapplicable nations for #{document_type}" do
        published_document = create("published_#{document_type}")
        northern_ireland_inapplicability = published_document.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
        scotland_inapplicability = published_document.nation_inapplicabilities.create!(nation: Nation.scotland)

        get :show, id: published_document.document

        assert_select inapplicable_nations_selector, "England and Wales (see #{published_document.format_name} for Northern Ireland)" do
          assert_select_object northern_ireland_inapplicability do
            assert_select "a[href='http://northern-ireland.com/']"
          end
          refute_select_object scotland_inapplicability
        end
      end
    end

    def should_paginate(edition_type, options={})
      include DocumentFilterHelpers
      options.reverse_merge!(timestamp_key: :first_published_at)

      test "index should only fetch a certain number of #{edition_type.to_s.pluralize} by default" do
        without_delay! do
          documents = (1..6).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}-index-default", options[:timestamp_key] => i.days.ago) }
          documents.sort_by!(&options[:sort_by]) if options[:sort_by]

          with_number_of_documents_per_page(3) do
            get :index
          end

          fetched_documents = assigns(:filter).documents
          (0..2).to_a.each { |i| assert fetched_documents.include?(documents[i]) }
          (3..5).to_a.each { |i| refute fetched_documents.include?(documents[i]) }
        end
      end

      test "index should fetch the correct page for #{edition_type}" do
        without_delay! do
          documents = (1..6).to_a.map { |i| create("published_#{edition_type}", title:   "keyword-#{i}-window-pagination", options[:timestamp_key] => i.days.ago) }
          documents.sort_by!(&options[:sort_by]) if options[:sort_by]

          with_number_of_documents_per_page(3) do
            get :index, page: 2
          end

          fetched_documents = assigns(:filter).documents
          (0..2).to_a.each { |i| refute fetched_documents.include?(documents[i]) }
          (3..5).to_a.each { |i| assert fetched_documents.include?(documents[i]) }
        end
      end

      view_test "show more button should not appear by default for #{edition_type}" do
        without_delay! do
          documents = (1..3).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

          with_number_of_documents_per_page(3) do
            get :index
          end

          refute_select "#show-more-documents"
        end
      end

      view_test "show more button should appear when there are more records for #{edition_type}" do
        without_delay! do
          documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

          with_number_of_documents_per_page(3) do
            get :index
          end

          assert_select "#show-more-documents"
        end
      end

      view_test "infinite pagination link should appear when there are more records for #{edition_type}" do
        without_delay! do
          documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

          with_number_of_documents_per_page(3) do
            get :index
          end

          assert_select "link[rel='next'][type='application/json']"
        end
      end

      view_test "should show previous page link when not on the first page for #{edition_type}" do
        without_delay! do
          documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

          with_number_of_documents_per_page(3) do
            get :index, page: 2
          end

          assert_select "#show-more-documents" do
            assert_select ".previous"
            refute_select ".next"
          end
        end
      end

      view_test "should show progress helpers in pagination links for #{edition_type}" do
        without_delay! do
          documents = (1..7).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

          with_number_of_documents_per_page(3) do
            get :index, page: 2
          end

          assert_select "#show-more-documents" do
            assert_select ".previous span", text: "1 of 3"
            assert_select ".next span", text: "3 of 3"
          end
        end
      end

      view_test "should preserve query params in next pagination link for #{edition_type}" do
        without_delay! do
          documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

          with_number_of_documents_per_page(3) do
            get :index, keywords: 'keyword'
          end

          assert_select "link[rel=next][type='application/json'][href*='keywords=keyword']"
        end
      end
    end

    def should_return_json_suitable_for_the_document_filter(document_type)
      include DocumentFilterHelpers

      view_test "index requested as JSON includes a count of #{document_type}" do
        without_delay! do
          create(:"published_#{document_type}")

          get :index, format: :json

          assert_equal 1, ActiveSupport::JSON.decode(response.body)["count"]
        end
      end

      view_test "index requested as JSON includes the total pages of #{document_type}" do
        without_delay! do
          4.times { create(:"published_#{document_type}") }

          with_number_of_documents_per_page(3) do
            get :index, format: :json
          end

          assert_equal 2, ActiveSupport::JSON.decode(response.body)["total_pages"]
        end
      end

      view_test "index requested as JSON includes the current page of #{document_type}" do
        without_delay! do
          create(:"published_#{document_type}")

          get :index, format: :json

          assert_equal 1, ActiveSupport::JSON.decode(response.body)["current_page"]
        end
      end
    end

    def should_show_local_government_items_for(document_type)
      test "index fetches #{document_type} items irrespective of relevance to local goverment by default" do
        without_delay! do
          announced_today = [create(:"published_#{document_type}", relevant_to_local_government: true), create(:"published_#{document_type}")]

          get :index

          fetched_documents = assigns(:filter).documents
          assert fetched_documents.include?(announced_today[0])
          assert fetched_documents.include?(announced_today[1])
        end
      end

      test "index fetches only local government #{document_type} only when asked for" do
        without_delay! do
          announced_today = [create(:"published_#{document_type}", relevant_to_local_government: true), create(:"published_#{document_type}")]

          get :index, relevant_to_local_government: 1

          fetched_documents = assigns(:filter).documents
          assert fetched_documents.include?(announced_today[0])
          refute fetched_documents.include?(announced_today[1])
        end
      end

      view_test "index doesn't show local government checkbox if turned off for #{document_type}" do
        Whitehall.stubs('local_government_features?').returns(false)
        get :index, relevant_to_local_government: 1

        refute_select "input[name='relevant_to_local_government']"
      end
    end
  end

  private

  def controller_attributes_for_instance(edition, attribute_overrides = {})
    attributes = edition.attributes
    attributes['lead_organisation_ids'] = edition.lead_organisations.map(&:id).map(&:to_s) if edition.respond_to?(:lead_organisations)
    attributes.deep_merge(attribute_overrides)
  end

  def controller_attributes_for(edition_type, attributes = {})
    attributes = attributes.merge(
      lead_organisation_ids: [(Organisation.first || create(:organisation)).id]
    )
    attributes_for(edition_type, attributes)
  end
end
