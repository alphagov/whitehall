require 'test_helper'

class MainstreamCategoryTest < ActiveSupport::TestCase
  setup do
    @category = MainstreamCategory.new(title: "Hirsuteness",
      identifier: "http://some.thing/tags/hirsuteness.json",
      parent_title: "Grooming")
  end

  test "is valid with a title, identifier, parent_title" do
    assert @category.valid?
  end

  test "is invalid without title" do
    @category.title = nil
    refute @category.valid?
  end

  test "is invalid without identifier" do
    @category.identifier = nil
    refute @category.valid?
  end

  test "is invalid without parent_title" do
    @category.parent_title = nil
    refute @category.valid?
  end

  test "is not valid with an identifier that doesn't start with http(s?)://" do
    @category.identifier = "example.com/tags/blah.json"
    refute @category.valid?
    assert @category.errors[:identifier].include?("must start with http or https")
  end

  test "is not valid with an identifier that doesn't contain /tags/" do
    @category.identifier = "http://example.com/blah.json"
    refute @category.valid?
    assert @category.errors[:identifier].include?("must contain /tags/")
  end

  test "is not valid with an identifier that doesn't end in .json" do
    @category.identifier = "https://example.com/tags/blah"
    refute @category.valid?
    assert @category.errors[:identifier].include?("must end with .json")
  end

  test "slug is generated from last path part of the identifier" do
    @category.identifier = "http://some.thing/tags/category%2Fsubcategory.json"
    assert_equal "subcategory", @category.generate_slug
  end

  test "slug is set automatically on save" do
    @category.expects(:generate_slug).returns("my-slug")
    @category.save!
    assert_equal 'my-slug', @category.reload.slug
  end

  test "slug is used for to_param" do
    @category.expects(:slug).returns("my-slug")
    assert_equal "my-slug", @category.to_param
  end

  test "has many detailed guides via primary and other relationships" do
    primary_detailed_guide_a = create(:draft_detailed_guide, primary_mainstream_category: @category)
    primary_detailed_guide_b = create(:draft_detailed_guide, primary_mainstream_category: @category)
    other_detailed_guide_a = create(:draft_detailed_guide, other_mainstream_categories: [@category])
    other_detailed_guide_b = create(:draft_detailed_guide, other_mainstream_categories: [@category])

    assert_same_elements [primary_detailed_guide_a, primary_detailed_guide_b,
                          other_detailed_guide_a, other_detailed_guide_b],
                         @category.detailed_guides
  end

  test "can return only published detailed guides" do
    draft_primary_detailed_guide = create(:draft_detailed_guide, primary_mainstream_category: @category)
    published_primary_detailed_guide = create(:published_detailed_guide, primary_mainstream_category: @category)
    draft_other_detailed_guide = create(:draft_detailed_guide, other_mainstream_categories: [@category])
    published_other_detailed_guide = create(:published_detailed_guide, other_mainstream_categories: [@category])

    assert_same_elements [published_primary_detailed_guide,
                          published_other_detailed_guide],
                         @category.published_detailed_guides
  end
end
