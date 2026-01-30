module AdminEditionController
  module TopicalEventsTests
    extend ActiveSupport::Concern

    included do
      view_test "new should display topical events field" do
        get :new

        assert_select "form#new_edition" do
          assert_select "label[for=edition_topical_event_ids]", text: "Topical events"

          assert_select "#edition_topical_event_ids" do |elements|
            assert_equal 1, elements.length
          end
        end
      end

      test "create should associate topical events with the edition" do
        first_topical_event = create(:topical_event)
        second_topical_event = create(:topical_event)
        attributes = controller_attributes_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 topical_event_ids: [first_topical_event.id, second_topical_event.id],
               ),
             }

        edition = edition_class.last!
        assert_equal [first_topical_event, second_topical_event], edition.topical_events
      end

      view_test "edit should display topical events field" do
        edition = create("draft_#{edition_type}")

        get :edit, params: { id: edition }

        assert_select "form#edit_edition" do
          assert_select "label[for=edition_topical_event_ids]", text: "Topical events"

          assert_select "#edition_topical_event_ids" do |elements|
            assert_equal 1, elements.length
          end
        end
      end

      test "update should associate topical events with the edition" do
        first_topical_event = create(:topical_event)
        second_topical_event = create(:topical_event)

        edition = create("draft_#{edition_type}", topical_events: [first_topical_event])

        put :update,
            params: {
              id: edition,
              edition: {
                topical_event_ids: [second_topical_event.id],
              },
            }

        edition.reload
        assert_equal [second_topical_event], edition.topical_events
      end
    end

  private

    def edition_class
      @edition_class ||= edition_type.to_s.classify.constantize
    end
  end
end
