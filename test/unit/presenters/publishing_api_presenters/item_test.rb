require "test_helper"

class PublishingApiPresenters::ItemTest < ActiveSupport::TestCase
  # FIXME: this test is overly dependent on the implementation of a child
  # presenter class (Organisation). These presenters will be reworked to remove
  # this inheritance relationship, and this test should be reworked so that it
  # tests the Item presenter in isolation.
  test 'is locale aware' do
    test_item = build_stubbed(:organisation)
    presenter = PublishingApiPresenters::Organisation.new(test_item)

    I18n.with_locale :fr do
      test_item.name = "French name"
      test_item.save!

      assert_equal presenter.content[:locale], "fr"
      assert_equal 'fr', presenter.content[:locale]
      assert_equal 'French name', presenter.content[:title]
      assert_equal(
        Whitehall.url_maker.organisation_path(test_item, locale: :fr),
        presenter.content[:routes].first[:path]
      )
    end
  end
end
