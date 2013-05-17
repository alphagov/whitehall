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

  test 'English editions fallback to their English translation when localised' do
    edition = create(:edition, title: 'English Title', body: 'English Body')

    with_locale(:fr) do
      assert_equal 'English Title', edition.title
      assert_equal 'English Body', edition.body
      edition.title = 'French Title'
      assert_equal 'French Title', edition.title
      assert_equal 'English Body', edition.body
    end

    assert_equal 'English Title', edition.title
    assert_equal 'English Body', edition.body
  end

  test 'non-English editions fallback to their primary locale when localised, even with English translation' do
    I18n.locale = :fr
    french_edition = create(:edition, title: 'French Title', body: 'French Body', primary_locale: :fr)

    with_locale(:en) do
      french_edition.title = 'English Title'
      french_edition.save!
      assert_equal 'English Title', french_edition.title
    end

    I18n.locale = :es
    assert_equal 'French Title', french_edition.title
    assert_equal 'French Body', french_edition.body
  end
end
