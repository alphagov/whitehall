require "test_helper"

class Edition::TranslatableTest < ActiveSupport::TestCase
  test "returns the non-english locales that this edition is yet to be translated into" do
    Locale.stubs(:non_english).returns([Locale.new(:es), Locale.new(:fr)])
    edition = create(:edition)
    with_locale(:es) { edition.update_attributes(attributes_for(:edition)) }
    assert_equal [Locale.new(:fr)], edition.missing_translations
  end
end
