require 'test_helper'

class MainstreamCategoryTest < ActiveSupport::TestCase
  setup do
    @category = build(:mainstream_category)
  end

  test "should be invalid without title" do
    @category.title = nil
    refute @category.valid?
  end

  test "should be invalid without slug" do
    @category.title = nil
    refute @category.valid?
  end

  test "should be invalid without parent_title" do
    @category.parent_title = nil
    refute @category.valid?
  end

  test "should be invalid without parent_tag" do
    @category.parent_tag = nil
    refute @category.valid?
  end

  test "path is generated from parent_tag and slug" do
    @category.parent_tag = "category/subcategory"
    @category.slug = "subsubcategory"
    assert_equal "category/subcategory/subsubcategory", @category.path
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

  test "can limit categories returned to only those with published content" do
    @category_with_drafts = create(:mainstream_category)
    @empty_category = create(:mainstream_category)

    create(:published_detailed_guide, primary_mainstream_category: @category)
    create(:draft_detailed_guide, primary_mainstream_category: @category_with_drafts)

    assert_same_elements [@category], MainstreamCategory.with_published_content
  end

  test "with_published_content includes non primary categories" do
    @other_category = create(:mainstream_category)

    create(:published_detailed_guide, primary_mainstream_category: @category,
                                      other_mainstream_categories: [@other_category])

    assert_same_elements [@category, @other_category], MainstreamCategory.with_published_content
  end

  test "with_published_content should allow additional filtering" do
    @other_category = create(:mainstream_category, parent_tag: "some/parent/tag")

    create(:published_detailed_guide, primary_mainstream_category: @category)
    create(:published_detailed_guide, primary_mainstream_category: @other_category)

    assert_same_elements [@other_category], MainstreamCategory.with_published_content.where(parent_tag: "some/parent/tag")
  end

  test "with_published_content only returns each category once" do
    @other_category = create(:mainstream_category, parent_tag: "some/parent/tag")

    create(:published_detailed_guide, primary_mainstream_category: @category)
    create(:published_detailed_guide, primary_mainstream_category: @other_category, other_mainstream_categories: [@category])

    assert_same_elements [@category, @other_category], MainstreamCategory.with_published_content
  end
end
