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
    @model.stubs(:translated_locales).returns(%i[en fr])
    assert @model.available_in_multiple_languages?
  end

  test 'is available in multiple languages if only available in a non-english language' do
    @model.stubs(:translated_locales).returns([:fr])
    assert @model.available_in_multiple_languages?
  end

  test "returns the non-english locales that this model has been translated into" do
    Locale.stubs(:non_english).returns([Locale.new(:es), Locale.new(:fr)])
    @model.stubs(:translated_locales).returns(%i[en es])
    assert_equal [Locale.new(:es)], @model.non_english_translated_locales
  end

  test "returns the non-english locales that this model is yet to be translated into" do
    Locale.stubs(:non_english).returns([Locale.new(:es), Locale.new(:fr)])
    @model.stubs(:translated_locales).returns(%i[en es])
    assert_equal [Locale.new(:fr)], @model.missing_translations
  end
end
