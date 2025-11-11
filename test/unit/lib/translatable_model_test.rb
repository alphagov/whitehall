require "test_helper"

class TranslatableModelTest < ActiveSupport::TestCase
  setup do
    @model = stub("model")
    @model.extend(TranslatableModel)
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
