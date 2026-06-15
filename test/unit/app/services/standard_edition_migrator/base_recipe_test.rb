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

  test "defines noop methods for ignore_legacy_content_fields, ignore_new_content_fields, ignore_legacy_links, and ignore_new_links" do
    recipe = StandardEditionMigrator::BaseRecipe.new

    content = { "field" => "value" }
    links = { "link" => "value" }

    assert_equal content, recipe.ignore_legacy_content_fields(content)
    assert_equal content, recipe.ignore_new_content_fields(content)
    assert_equal links, recipe.ignore_legacy_links(links)
    assert_equal links, recipe.ignore_new_links(links)
  end
end
