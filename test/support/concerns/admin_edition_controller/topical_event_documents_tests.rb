module AdminEditionController
  module TopicalEventDocumentsTests
    extend ActiveSupport::Concern

    included do
      view_test "new should not display topical event documents field when flag is disabled" do
        get :new

        assert_select "form#new_edition" do
          assert_select "label[for=edition_topical_event_document_ids]", text: "Topical events (experimental)", count: 0
          assert_select "#edition_topical_event_document_ids", count: 0
        end
      end

      view_test "new should display topical event documents field when flag is enabled" do
        test_strategy = Flipflop::FeatureSet.current.test!
        test_strategy.switch!(:configurable_document_types, true)
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("topical_event"))
        topical_events = create_list(:published_standard_edition, 2, configurable_document_type: "topical_event")
        get :new

        assert_select "form#new_edition" do
          assert_select "label[for=edition_topical_event_document_ids]", text: "Topical events (experimental)"

          assert_select "#edition_topical_event_document_ids" do |elements|
            assert_equal 1, elements.length
          end

          topical_events.each do |event|
            assert_select "#edition_topical_event_document_ids option[value=\"#{event.document_id}\"]", text: event.title
          end
        end
        test_strategy.switch!(:configurable_document_types, false)
      end

      test "create should associate topical event documents with the edition" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("topical_event"))
        first_topical_event = create(:standard_edition, configurable_document_type: "topical_event")
        second_topical_event = create(:standard_edition, configurable_document_type: "topical_event")
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 topical_event_document_ids: [first_topical_event.document_id, second_topical_event.document_id],
               ),
             }

        edition = edition_type_class.last!
        assert_equal [first_topical_event.document, second_topical_event.document], edition.topical_event_documents
      end

      view_test "edit should display topical event documents field when flag is enabled" do
        test_strategy = Flipflop::FeatureSet.current.test!
        test_strategy.switch!(:configurable_document_types, true)
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("topical_event"))
        topical_events = create_list(:published_standard_edition, 2, configurable_document_type: "topical_event")
        edition = create("draft_#{edition_type}", topical_event_documents: topical_events.map(&:document))

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          assert_select "label[for=edition_topical_event_document_ids]", text: "Topical events (experimental)"

          assert_select "#edition_topical_event_document_ids" do |elements|
            assert_equal 1, elements.length
          end

          topical_events.each do |event|
            assert_select "#edition_topical_event_document_ids option[value=\"#{event.document_id}\"][selected=\"selected\"]", text: event.title
          end
        end
        test_strategy.switch!(:configurable_document_types, false)
      end

      test "update should associate topical event documents with the edition" do
        ConfigurableDocumentType.setup_test_types(build_configurable_document_type("topical_event"))
        first_topical_event = create(:standard_edition, configurable_document_type: "topical_event")
        second_topical_event = create(:standard_edition, configurable_document_type: "topical_event")
        edition = create("draft_#{edition_type}", topical_event_documents: [first_topical_event.document])

        put :update,
            params: {
              id: edition,
              edition: {
                topical_event_document_ids: [second_topical_event.document_id],
              },
            }

        edition.reload
        assert_equal [second_topical_event.document], edition.topical_event_documents
      end
    end

  private

    def edition_type_class
      self.class.class_for(edition_type)
    end
  end
end
