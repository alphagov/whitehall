module AdminEditionController::FirstPublishedAtOverridingTests
  extend ActiveSupport::Concern

  included do
    def edition_type_class
      self.class.class_for(edition_type)
    end

    test "create should save overridden first_published_at attribute" do
      first_published_at = 3.months.ago
      post :create,
           params: {
             edition: controller_attributes_for(edition_type).merge(first_published_at: 3.months.ago, previously_published: "true"),
           }

      edition = edition_type_class.last
      assert_equal first_published_at, edition.first_published_at
    end

    test "update should save overridden first_published_at attribute" do
      edition = create(edition_type) # rubocop:disable Rails/SaveBang
      first_published_at = 3.months.ago

      put :update,
          params: {
            id: edition,
            edition: {
              first_published_at:,
            },
          }

      edition.reload
      assert_equal first_published_at, edition.first_published_at
    end

    test "updates first_published_at to nil when previously_published is false" do
      edition = create(edition_type) # rubocop:disable Rails/SaveBang
      first_published_at = 3.months.ago

      patch :update, params: {
        id: edition,
        edition: {
          previously_published: "false",
          first_published_at:,
        },
      }

      assert_nil edition.reload.first_published_at
    end
  end
end
