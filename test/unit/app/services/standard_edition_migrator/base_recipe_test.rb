require "test_helper"

class BaseRecipeTest < ActiveSupport::TestCase
  test "raises exception if legacy_presenter method is called" do
    error = assert_raises(NotImplementedError) do
      StandardEditionMigrator::BaseRecipe.new.legacy_presenter
    end
    assert_equal "Subclasses must implement legacy_presenter!", error.message
  end

  test "raises exception if build_edition method is called" do
    error = assert_raises(NotImplementedError) do
      StandardEditionMigrator::BaseRecipe.new.build_edition(nil)
    end
    assert_equal "Subclasses must implement build_edition!", error.message
  end
end
