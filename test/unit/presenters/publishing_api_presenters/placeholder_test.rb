require 'test_helper'

class PublishingApiPresenters::PlaceholderTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApiPresenters::Placeholder.new(model_instance, options)
  end

  test 'update type can be overridden by passing an update_type option' do
    update_type_override = 'republish'
    organisation = create(:organisation)
    presented_item = present(organisation, update_type: update_type_override)
    assert_equal update_type_override, presented_item.update_type
  end

  test 'is locale aware' do
    organisation = create(:organisation)

    I18n.with_locale :fr do
      organisation.name = "French name"
      organisation.save!
      presented_item = present(organisation)

      assert_equal 'fr', presented_item.content[:locale]
      assert_equal 'French name', presented_item.content[:title]
      assert_equal Whitehall.url_maker.organisation_path(organisation, locale: :fr),
        presented_item.content[:routes].first[:path]
    end
  end
end
