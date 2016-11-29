require "test_helper"

class WithTranslationsTest < ActiveSupport::TestCase
  setup do
    role = build(:ministerial_role)
    with_locale(:en) do
      role.name = 'Minister of fun'
    end
    with_locale(:fr) do
      role.name = "Ministre de l'amusement"
    end
    role.save!
  end

  test "with_translations with no arguments returns each item once only" do
    assert_equal 1, Role.with_translations.count
  end

  test "with_translations with no arguments preloads all the translations on each item" do
    loaded_role = Role.with_translations.first

    query_count = count_queries { loaded_role.name }
    assert_equal 0, query_count
  end
end
