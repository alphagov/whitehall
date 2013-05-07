require "test_helper"

class Edition::TranslatableTest < ActiveSupport::TestCase
  teardown { I18n.locale = I18n.default_locale }

  test 'primary_locale defaults to English locale key' do
    assert_equal 'en', Edition.new.primary_locale
  end

  test 'primary_locale is validated as a locale' do
    edition = build(:edition, primary_locale: '123')
    refute edition.valid?
    assert_equal ['is not a valid locale'], edition.errors[:primary_locale]

    edition.primary_locale = :fr
    assert edition.valid?
    edition.primary_locale = 'fr'
    assert edition.valid?
  end
end
