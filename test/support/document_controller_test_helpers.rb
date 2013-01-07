module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_display_attachments_for(document_type)
      test "show displays document attachments" do
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

      test "show information about accessibility" do
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

      test "show alternative format contact email if given" do
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

      test "show displays PDF attachment metadata" do
        greenpaper_pdf = fixture_file_upload('greenpaper.pdf', 'application/pdf')
        attachment = create(:attachment, file: greenpaper_pdf)
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1", attachments: [attachment])

        get :show, id: edition.document

        assert_select_object(attachment) do
          assert_select ".type", /PDF/
          assert_select ".page-length", "1 page"
          assert_select ".file-size", "3.39 KB"
        end
      end

      test "show displays non-PDF attachment metadata" do
        csv = fixture_file_upload('sample-from-excel.csv', 'text/csv')
        attachment = create(:attachment, file: csv)
        edition = create("published_#{document_type}", :with_alternative_format_provider, body: "!@1", attachments: [attachment])

        get :show, id: edition.document

        assert_select_object(attachment) do
          assert_select ".type", /CSV/
          refute_select ".page-length"
          assert_select ".file-size", "121 Bytes"
        end
      end
    end

    def should_display_inline_images_for(document_type)
      test "show displays #{document_type} with inline images" do
        images = [create(:image), create(:image)]
        edition = create("published_#{document_type}", body: "!!2", images: images)

        get :show, id: edition.document

        assert_select 'article .body figure.image.embedded img'
      end
    end

    def should_show_related_policies_for(document_type)
      test "show displays related published policies for #{document_type}" do
        published_policy = create(:published_policy)
        edition = create("published_#{document_type}", related_policies: [published_policy])
        get :show, id: edition.document
        assert_select_object published_policy
      end

      test "show doesn't display related unpublished policies for #{document_type}" do
        draft_policy = create(:draft_policy)
        edition = create("published_#{document_type}", related_policies: [draft_policy])
        get :show, id: edition.document
        refute_select_object draft_policy
      end

      test "should not display policies unless they are related for #{document_type}" do
        unrelated_policy = create(:published_policy)
        edition = create("published_#{document_type}", related_policies: [])
        get :show, id: edition.document
        refute_select_object unrelated_policy
      end

      test "should not display an empty list of related policies for #{document_type}" do
        edition = create("published_#{document_type}")
        get :show, id: edition.document
        refute_select "#related-policies"
      end
    end

    def should_show_related_policies_and_topics_for(document_type)
      should_show_related_policies_for document_type

      test "show infers topics from published policies for #{document_type}" do
        topic = create(:topic)
        published_policy = create(:published_policy, topics: [topic])
        edition = create("published_#{document_type}", related_policies: [published_policy])
        get :show, id: edition.document
        assert_select_object topic
      end

      test "show doesn't display duplicate inferred topics for #{document_type}" do
        topic = create(:topic)
        published_policy_1 = create(:published_policy, topics: [topic])
        published_policy_2 = create(:published_policy, topics: [topic])
        edition = create("published_#{document_type}", related_policies: [published_policy_1, published_policy_2])
        get :show, id: edition.document
        assert_select_object topic, count: 1
      end
    end

    def should_show_the_world_locations_associated_with(document_type)
      test "should display the world locations associated with this #{document_type}" do
        first_location = create(:country)
        second_location = create(:overseas_territory)
        third_location = create(:international_delegation)
        edition = create("published_#{document_type}", world_locations: [first_location, second_location])

        get :show, id: edition.document

        assert_select '.document-world-locations' do
          assert_select "##{dom_id(first_location)}", text: first_location.name
          assert_select "##{dom_id(second_location)}", text: second_location.name
          assert_select "##{dom_id(third_location)}", count: 0
        end
      end

      test "should not display an empty list of world locations for #{document_type}" do
        edition = create("published_#{document_type}", world_locations: [])

        get :show, id: edition.document

        assert_select metadata_nav_selector do
          refute_select '.world-location'
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
      should_show_change_notes_on_action(document_type, :show) do |edition|
        get :show, id: edition.document
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
        first_edition = create("published_#{document_type}",
                               published_at: 1.months.ago,
                               first_published_at: 2.months.ago)
        document = first_edition.document
        draft_edition = create("draft_#{document_type}",
                               document: document,
                               body: "Draft information")

        login_as create(:departmental_editor)
        get :show, id: document.id, preview: draft_edition.id
        assert_response 200
      end

      test "#{document_type} preview should be hidden from public" do
        first_edition = create("published_#{document_type}",
                               published_at: 1.months.ago,
                               first_published_at: 2.months.ago)
        document = first_edition.document
        draft_edition = create("draft_#{document_type}",
                               document: document,
                               body: "Draft information")

        get :show, id: document.id, preview: draft_edition.id
        assert_response 404
      end
    end

    def should_show_change_notes_on_action(document_type, action, &block)
      test "#{action} displays default change note for first edition of #{document_type}" do
        first_edition = create("published_#{document_type}",
                               change_note: nil,
                               published_at: 1.month.ago)

        instance_exec(first_edition, &block)

        assert_select ".change-notes" do
          assert_select ".published-at[title='#{first_edition.first_published_date.iso8601}']"
        end
      end

      test "#{action} does not display blank change notes in change history for #{document_type}" do
        second_edition = create("published_#{document_type}",
                                change_note: nil,
                                minor_change: true,
                                published_at: 1.months.ago,
                                first_published_at: 2.months.ago)
        document = second_edition.document
        first_edition = create("archived_#{document_type}",
                               change_note: "First effort.",
                               document: document,
                               published_at: 2.months.ago,
                               first_published_at: 2.months.ago)

        instance_exec(second_edition, &block)

        assert_select ".change-notes" do
          refute_select ".published-at[title='#{second_edition.published_at.iso8601}']"
          refute_select "dt", text: ""
        end
      end

      test "#{action} displays change history in reverse chronological order for #{document_type}" do
        editions = []
        editions << create("published_#{document_type}",
                           change_note: "Third go.",
                           published_at: 1.month.ago,
                           first_published_at: 3.months.ago)
        document = editions.first.document
        editions << create("archived_#{document_type}",
                           change_note: "Second attempt.",
                           document: document,
                           published_at: 2.months.ago,
                           first_published_at: 3.months.ago)
        editions << create("archived_#{document_type}",
                           change_note: "First effort.",
                           document: document,
                           published_at: 3.months.ago,
                           first_published_at: 3.months.ago)

        instance_exec(editions.first, &block)

        assert_select ".change-notes dd" do |list_items|
          list_items.each_with_index do |list_item, index|
            if index == ( list_items.length-1 )
              assert_select list_item, ".published-at[title='#{editions[index].first_published_date.iso8601}']"
            else
              assert_select list_item, ".published-at[title='#{editions[index].published_at.iso8601}']"
            end
          end
        end
        assert_select ".change-notes dt" do |list_items|
          list_items.each_with_index do |list_item, index|
            assert_select list_item, 'dt', text: editions[index].change_note
          end
        end
      end
    end

    def should_show_inapplicable_nations(document_type)
      test "show displays inapplicable nations for #{document_type}" do
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

      test "index should only show a certain number of #{edition_type.to_s.pluralize} by default" do
        documents = (1..6).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}-index-default", options[:timestamp_key] => i.days.ago) }
        documents.sort_by!(&options[:sort_by]) if options[:sort_by]

        with_number_of_documents_per_page(3) do
          get :index
        end

        (0..2).to_a.each { |i| assert_select_object(documents[i]) }
        (3..5).to_a.each { |i| refute_select_object(documents[i]) }
      end

      test "index should show window of pagination for #{edition_type}" do
        documents = (1..6).to_a.map { |i| create("published_#{edition_type}", title:   "keyword-#{i}-window-pagination", options[:timestamp_key] => i.days.ago) }
        documents.sort_by!(&options[:sort_by]) if options[:sort_by]

        with_number_of_documents_per_page(3) do
          get :index, page: 2
        end

        (0..2).to_a.each { |i| refute_select_object(documents[i]) }
        (3..5).to_a.each { |i| assert_select_object(documents[i]) }
      end

      test "show more button should not appear by default for #{edition_type}" do
        documents = (1..3).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

        with_number_of_documents_per_page(3) do
          get :index
        end

        refute_select "#show-more-documents"
      end

      test "show more button should appear when there are more records for #{edition_type}" do
        documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

        with_number_of_documents_per_page(3) do
          get :index
        end

        assert_select "#show-more-documents"
      end

      test "infinite pagination link should appear when there are more records for #{edition_type}" do
        documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

        with_number_of_documents_per_page(3) do
          get :index
        end

        assert_select "link[rel='next'][type='application/json']"
      end

      test "should show previous page link when not on the first page for #{edition_type}" do
        documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

        with_number_of_documents_per_page(3) do
          get :index, page: 2
        end

        assert_select "#show-more-documents" do
          assert_select ".previous"
          refute_select ".next"
        end
      end

      test "should show progress helpers in pagination links for #{edition_type}" do
        documents = (1..7).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

        with_number_of_documents_per_page(3) do
          get :index, page: 2
        end

        assert_select "#show-more-documents" do
          assert_select ".previous span", text: "1 of 3"
          assert_select ".next span", text: "3 of 3"
        end
      end

      test "should preserve query params in next pagination link for #{edition_type}" do
        documents = (1..4).to_a.map { |i| create("published_#{edition_type}", title: "keyword-#{i}") }

        with_number_of_documents_per_page(3) do
          get :index, keywords: 'keyword'
        end

        assert_select "link[rel=next][type='application/json'][href*='keywords=keyword']"
      end
    end

    def should_return_json_suitable_for_the_document_filter(document_type)
      include DocumentFilterHelpers

      test "index requested as JSON includes a count of #{document_type}" do
        create(:"published_#{document_type}")

        get :index, format: :json

        assert_equal 1, ActiveSupport::JSON.decode(response.body)["count"]
      end

      test "index requested as JSON includes the total pages of #{document_type}" do
        4.times { create(:"published_#{document_type}") }

        with_number_of_documents_per_page(3) do
          get :index, format: :json
        end

        assert_equal 2, ActiveSupport::JSON.decode(response.body)["total_pages"]
      end

      test "index requested as JSON includes the current page of #{document_type}" do
        create(:"published_#{document_type}")

        get :index, format: :json

        assert_equal 1, ActiveSupport::JSON.decode(response.body)["current_page"]
      end
    end
  end

  private

  def controller_attributes_for_instance(edition, attribute_overrides = {})
    attributes = edition.attributes
    attributes['edition_organisations_attributes'] = edition.lead_edition_organisations.map(&:attributes) if edition.respond_to?(:lead_organisation_editions)
    attributes.deep_merge(attribute_overrides)
  end

  def controller_attributes_for(edition_type, attributes = {})
    attributes = attributes.merge(
      edition_organisations_attributes: [{id: '', lead: '1', lead_ordering: '1', organisation_id: (Organisation.first || create(:organisation)).id}]
    )
    attributes_for(edition_type, attributes)
  end
end
