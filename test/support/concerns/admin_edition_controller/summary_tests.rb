module AdminEditionController
  module SummaryTests
    extend ActiveSupport::Concern

    included do
      test "create should create a new edition with summary" do
        attributes = controller_attributes_for(edition_type)
        edition_class = class_for(edition_type)

        post :create,
             params: {
               edition: attributes.merge(
                 summary: "my summary",
               ),
             }

        created_edition = edition_class.last
        assert_equal "my summary", created_edition.summary
      end

      test "update should save modified edition summary" do
        edition = create!(edition_type)

        put :update,
            params: {
              id: edition,
              edition: {
                summary: "new-summary",
              },
            }

        edition.reload
        assert_equal "new-summary", edition.summary
      end
    end

  private

    # This method is expected to be defined in the test class
    # that includes this concern.
    def edition_type
      raise NotImplementedError, "You must define `edition_type` in your test class."
    end
  end
end
