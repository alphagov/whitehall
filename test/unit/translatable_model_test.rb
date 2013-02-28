require 'test_helper'

class TranslatableModelTest < ActiveSupport::TestCase
  setup do
    @model = stub('model')
    @model.extend(TranslatableModel)
  end

  test 'is not available in multiple languages if only available in english' do
    @model.stubs(:translated_locales).returns([:en])
    refute @model.available_in_multiple_languages?
  end

  test 'is available in multiple languages if available in english and one or more other languages' do
    @model.stubs(:translated_locales).returns([:en, :fr])
    assert @model.available_in_multiple_languages?
  end

  test 'is available in multiple languages if only available in a non-english language' do
    @model.stubs(:translated_locales).returns([:fr])
    assert @model.available_in_multiple_languages?
  end
end
