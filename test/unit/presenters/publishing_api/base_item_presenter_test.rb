require "test_helper"

module PublishingApi
  class BaseItemPresenterTest < ActiveSupport::TestCase
    test "it returns the base set of attributes needed by all documents sent to the publishing API" do
      stubbed_item = stub(title: 'A title')

      presenter = PublishingApi::BaseItemPresenter.new(stubbed_item, update_type: "major", locale: "fr")
      expected_hash = {
        title: stubbed_item.title,
        locale: "fr",
        publishing_app: "whitehall",
        redirects: [],
        update_type: "major",
      }

      assert_equal presenter.base_attributes, expected_hash
    end
  end
end
