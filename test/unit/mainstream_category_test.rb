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

  test "has many specialist guides via primary and other relationships" do
    primary_specialist_guide_a = create(:draft_specialist_guide, primary_mainstream_category: @category)
    primary_specialist_guide_b = create(:draft_specialist_guide, primary_mainstream_category: @category)
    other_specialist_guide_a = create(:draft_specialist_guide, other_mainstream_categories: [@category])
    other_specialist_guide_b = create(:draft_specialist_guide, other_mainstream_categories: [@category])

    assert_same_elements [primary_specialist_guide_a, primary_specialist_guide_b,
                          other_specialist_guide_a, other_specialist_guide_b],
                         @category.specialist_guides
  end

  test "can return only published specialist guides" do
    draft_primary_specialist_guide = create(:draft_specialist_guide, primary_mainstream_category: @category)
    published_primary_specialist_guide = create(:published_specialist_guide, primary_mainstream_category: @category)
    draft_other_specialist_guide = create(:draft_specialist_guide, other_mainstream_categories: [@category])
    published_other_specialist_guide = create(:published_specialist_guide, other_mainstream_categories: [@category])

    assert_same_elements [published_primary_specialist_guide,
                          published_other_specialist_guide],
                         @category.published_specialist_guides
  end
end
