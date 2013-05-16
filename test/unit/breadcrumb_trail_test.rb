require "test_helper"

class BreadcrumbTrailTest < ActiveSupport::TestCase
  test "should build hash suitable for slimmer from detailed guide" do
    mainstream_category = create(:mainstream_category, parent_tag: "business/tax")
    detailed_guide = create(:detailed_guide, title: "detailed-guide-title", primary_mainstream_category: mainstream_category)
    content_api = stub("content-api")
    content_api.expects(:tag).with(mainstream_category.parent_tag).returns(business_tax_tag)

    with_mainstream_content_api(content_api) do
      breadcrumb_trail = BreadcrumbTrail.for(detailed_guide)
      assert breadcrumb_trail.valid?

      assert_equal "detailed-guide-title", breadcrumb_trail.to_hash[:title]
      assert_equal "detailedguidance", breadcrumb_trail.to_hash[:format]
      assert_equal routes_helper.public_document_path(detailed_guide), breadcrumb_trail.to_hash[:web_url]

      actual_tag = breadcrumb_trail.to_hash[:tags].first
      assert_equal mainstream_category.title, actual_tag[:title]
      assert_equal mainstream_category.path, actual_tag[:id]
      assert_equal nil, actual_tag[:web_url]
      assert_equal({type: 'section'}, actual_tag[:details])
      assert_equal({
        id: mainstream_category.path,
        web_url: routes_helper.mainstream_category_path(mainstream_category)
      }, actual_tag[:content_with_tag])
      assert_equal(business_tax_tag.to_hash, actual_tag[:parent])
    end
  end

  test "should build hash from detailed guide even when content API has no metadata" do
    detailed_guide = create(:detailed_guide)
    with_mainstream_content_api(stub("content-api", tag: nil)) do
      assert BreadcrumbTrail.for(detailed_guide).to_hash[:tags][0][:parent].empty?
    end
  end

  test "should be invalid if no parent tag" do
    category = build(:mainstream_category, parent_tag: nil)
    detailed_guide = build(:detailed_guide, primary_mainstream_category: category)

    with_mainstream_content_api(stub("content-api")) do
      breadcrumb_trail = BreadcrumbTrail.for(detailed_guide)
      refute breadcrumb_trail.valid?
      assert_nil breadcrumb_trail.to_hash
    end
  end

  test "should build hash suitable for slimmer from mainstream_category" do
    mainstream_category = create(:mainstream_category, parent_tag: "business/tax")
    content_api = stub("content-api")
    content_api.expects(:tag).with(mainstream_category.parent_tag).returns(business_tax_tag)

    with_mainstream_content_api(content_api) do
      breadcrumb_trail = BreadcrumbTrail.for(mainstream_category)
      assert breadcrumb_trail.valid?

      artefact_hash = breadcrumb_trail.to_hash
      assert_equal mainstream_category.title, artefact_hash[:title]
      assert_equal "section", artefact_hash[:format]
      assert_equal routes_helper.mainstream_category_path(mainstream_category), artefact_hash[:web_url]
      assert_equal mainstream_category.path, artefact_hash[:id]

      assert_equal [business_tax_tag.to_hash], artefact_hash[:tags]
    end
  end

private
  def business_tax_tag
    stub("business_tax_tag response", to_hash: {
      "_response_info" => {
        "status" => "ok"
      },
      "title" => "Tax",
      "id" => "http://gov.uk/tags/business%2Ftax.json",
      "web_url" => nil,
      "details" => {
        "description" => nil,
        "type" => "section"
      },
      "content_with_tag" => {
        "id" => "http://gov.uk/with_tag.json?tag=business%2Ftax",
        "web_url" => "https://www.preview.alphagov.co.uk/browse/business#/tax"
      },
      "parent" => {
        "title" => "Business",
        "id" => "http://gov.uk/tags/business.json",
        "web_url" => nil,
        "details" => {
          "description" => "Information about starting up and running a business in the UK, including help if you're self employed or a sole trader.",
          "type" => "section"
        },
        "content_with_tag" => {
          "id" => "http://gov.uk/with_tag.json?tag=business",
          "web_url" => "https://www.preview.alphagov.co.uk/browse/business"
        },
        "parent" => nil
      }
    })
  end
end