require "test_helper"

class RelatedMainstreamTest < ActiveSupport::TestCase
  test "raises an error if creating a record with a nil content_id" do
    detailed_guide = create(:detailed_guide)
    assert_raises StandardError, match: "Validation failed: Content cannot be blank" do
      RelatedMainstream.create!(edition_id: detailed_guide.id, content_id: nil)
    end
  end

  test "raises an error if creating a record with an existing content_id for the same edition" do
    detailed_guide = create(:detailed_guide)
    RelatedMainstream.create!(edition_id: detailed_guide.id, content_id: "5a2fea6a-360a-49ba-97b3-46d3612ec198")

    assert_raises StandardError, match: "Validation failed: Content has already been taken" do
      RelatedMainstream.create!(edition_id: detailed_guide.id, content_id: "5a2fea6a-360a-49ba-97b3-46d3612ec198", additional: true)
    end
    assert_equal 1, RelatedMainstream.count
  end

  test "raises an error if creating a record with a nil edition" do
    assert_raises StandardError, match: "Validation failed: Edition cannot be blank" do
      RelatedMainstream.create!(edition_id: nil, content_id: "5a2fea6a-360a-49ba-97b3-46d3612ec198")
    end
  end
end
