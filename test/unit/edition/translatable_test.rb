require "test_helper"

class Edition::TranslatableTest < ActiveSupport::TestCase
  teardown { I18n.locale = I18n.default_locale }

  test 'locale defaults to English locale key' do
    assert_equal 'en', Edition.new.locale
  end

  test 'locale is validated as a locale' do
    edition = build(:edition, locale: '123')
    refute edition.valid?
    assert_equal ['is not valid'], edition.errors[:locale]

    edition.locale = :fr
    assert edition.valid?
    edition.locale = 'fr'
    assert edition.valid?
  end

  test 'primary_language_name returns the native English lanugage name' do
    assert_equal 'English', Edition.new.primary_language_name
    assert_equal 'French', Edition.new(locale: :fr).primary_language_name
  end

  test 'locale_can_be_changed? returns true for a new WorldLocationNewsArticle' do
    assert WorldLocationNewsArticle.new.locale_can_be_changed?
  end

  test 'locale_can_be_changed? returns false for a persisted new WorldLocationNewsArticle' do
    refute create(:world_location_news_article).locale_can_be_changed?
  end

  test 'locale_can_be_changed? returns false for other edition types' do
    Edition.concrete_descendants.reject {|k| k == WorldLocationNewsArticle }.each do |klass|
      refute klass.new.locale_can_be_changed?, "Instance of #{klass} should not allow the changing of primary locale"
    end
  end

  test 'right-to-left editions identify themselves' do
    french_edition = create(:edition, locale: :fr)
    refute french_edition.rtl?

    arabic_edition = create(:edition, locale: :ar)
    assert arabic_edition.rtl?
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
    french_edition = create(:edition, title: 'French Title', body: 'French Body', locale: :fr)

    with_locale(:en) do
      french_edition.title = 'English Title'
      french_edition.save!
      assert_equal 'English Title', french_edition.title
    end

    I18n.locale = :es
    assert_equal 'French Title', french_edition.title
    assert_equal 'French Body', french_edition.body
  end

  test 'updating a non-English edition does not save an empty English translation' do
    french_edition = I18n.with_locale(:fr) { create(:edition, title: 'French Title', body: 'French Body', locale: :fr) }
    assert french_edition.available_in_locale?(:fr)
    refute french_edition.available_in_locale?(:en)

    force_publish(french_edition)

    assert french_edition.available_in_locale?(:fr)
    refute french_edition.available_in_locale?(:en)
  end
end
