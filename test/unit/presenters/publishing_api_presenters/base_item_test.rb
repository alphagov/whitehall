require "test_helper"

module PublishingApiPresenters
  class BaseItemTest < ActiveSupport::TestCase
    test "it returns the base set of attributes needed by all documents sent to the publishing API" do
      stubbed_item = stub(need_ids: [1, 2], title: 'A title')

      presenter = PublishingApiPresenters::BaseItem.new(stubbed_item, locale: "fr")
      expected_hash = {
        title: stubbed_item.title,
        locale: "fr",
        need_ids: stubbed_item.need_ids,
        publishing_app: "whitehall",
        redirects: [],
      }

      assert_equal presenter.base_attributes, expected_hash
    end
  end
end
