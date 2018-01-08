require 'test_helper'

class Edition::SpecialistSectorsTest < ActiveSupport::TestCase
  test '#create_draft should copy specialist sectors' do
    expected_primary_tag = 'tax/vat'
    expected_secondary_tags = ['oil-and-gas/taxation', 'tax/corporation-tax']
    edition = create(:published_publication, primary_specialist_sector_tag: expected_primary_tag, secondary_specialist_sector_tags: expected_secondary_tags)

    assert_equal 3, SpecialistSector.count

    draft = edition.create_draft(create(:writer))

    assert_equal expected_primary_tag, draft.primary_specialist_sector_tag
    assert_equal expected_secondary_tags, draft.secondary_specialist_sector_tags
    assert_equal 6, SpecialistSector.count
  end

  test "#specialist_sector_tags should return tags ordered from primary to secondary" do
    expected_primary_tag = 'tax/vat'
    expected_secondary_tags = ['oil-and-gas/taxation', 'tax/corporation-tax']

    edition = create(
      :published_edition,
      title: "edition-title",
      primary_specialist_sector_tag: expected_primary_tag,
      secondary_specialist_sector_tags: expected_secondary_tags,
    )

    assert_equal(
      [expected_primary_tag, expected_secondary_tags].flatten,
      edition.specialist_sector_tags
    )
  end

  test "#specialist_sector_tags should return an empty array for editions without specialist sectors" do
    edition_without_specialist_sectors = create(
      :edition,
      primary_specialist_sector_tag: nil,
      secondary_specialist_sector_tags: [],
    )

    assert_equal [], edition_without_specialist_sectors.specialist_sector_tags
  end

  test "moving a secondary tag to the primary tag doesn't fail" do
    tag = "environmental-management/waste"
    publication = create(:publication, secondary_specialist_sector_tags: [tag])
    publication.update_attributes(primary_specialist_sector_tag: tag,
      secondary_specialist_sector_tags: [])

    assert publication.save
    assert_equal tag, publication.primary_specialist_sector_tag
    assert_equal [], publication.secondary_specialist_sector_tags
  end

  test "users can remove a tag" do
    publication = create(:published_edition)

    publication.update_attributes!(primary_specialist_sector_tag: "environmental-management/waste")

    publication.update_attributes!(primary_specialist_sector_tag: nil)

    assert_nil publication.primary_specialist_sector_tag
  end
end
