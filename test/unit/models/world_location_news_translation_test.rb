require 'test_helper'

class WorldLocationNewsTranslationTest < ActiveSupport::TestCase
  test 'it is not available in multiple languages when initialised with nil' do
    world_location_news_translation = WorldLocationNewsTranslation.new(nil)

    refute world_location_news_translation.available_in_multiple_languages?
  end

  test 'it is not available in multiple languages when initialised with a single translated locale' do
    locales = [:en]

    world_location_news_translation = WorldLocationNewsTranslation.new(locales)

    refute world_location_news_translation.available_in_multiple_languages?
  end

  test 'it is not available in multiple languages when initialised with a single locale that is not an array' do
    locale = :en

    world_location_news_translation = WorldLocationNewsTranslation.new(locale)

    refute world_location_news_translation.available_in_multiple_languages?
  end

  test 'it is available in multiple languages when initialised with an array of translated locales' do
    locales = [:en, :fr]

    world_location_news_translation = WorldLocationNewsTranslation.new(locales)

    assert world_location_news_translation.available_in_multiple_languages?
  end

  test 'it returns an empty array as translated_locales when initialised with nil' do
    world_location_news_translation = WorldLocationNewsTranslation.new(nil)

    assert [], world_location_news_translation.translated_locales
  end

  test 'it returns a single available language in an array as translated_locales when a single language is passed in' do
    locale = :en
    locale_as_array = [:en]

    assert [:en], WorldLocationNewsTranslation.new(locale_as_array).translated_locales
    assert [:en], WorldLocationNewsTranslation.new(locale).translated_locales
  end

  test 'it returns the available languages as translated_locales' do
    locales = [:en, :fr]

    world_location_news_translation = WorldLocationNewsTranslation.new(locales)

    assert [:en, :fr], world_location_news_translation.translated_locales
  end
end
