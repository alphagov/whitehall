require "test_helper"

class Edition::WorldLocationsTest < ActiveSupport::TestCase
  test "#destroy should also remove the relationship" do
    edition = create(:draft_policy, world_locations: [create(:world_location)])
    relation = edition.edition_world_locations.first
    edition.destroy
    refute EditionWorldLocation.find_by_id(relation.id)
  end

  test "new edition of document featured in world_location should remain featured in that world_location with image and alt text" do
    featured_image = create(:edition_world_location_image_data)
    world_location = create(:world_location)
    news_article = create(:published_news_article, world_locations: [world_location])
    association = news_article.edition_world_locations.where(world_location_id: world_location).first
    association.image = featured_image
    association.alt_text = "alt-text"
    association.featured = true
    association.save!

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    new_edition_world_location = new_edition.edition_world_locations.where(world_location_id: world_location).first
    assert new_edition_world_location.featured?
    assert_equal featured_image, new_edition_world_location.image
    assert_equal "alt-text", new_edition_world_location.alt_text
  end

  test "new edition of document not featured in world_location should remain unfeatured in that world_location" do
    world_location = create(:world_location)
    news_article = create(:published_news_article, world_locations: [world_location])

    new_edition = news_article.create_draft(create(:policy_writer))
    new_edition.change_note = 'change-note'
    new_edition.publish_as(create(:departmental_editor), force: true)

    edition_world_location = new_edition.edition_world_locations.where(world_location_id: world_location).first
    refute edition_world_location.featured?
  end


  test "ensures that featured editions on worldwide pages have their associations preserved" do
    image_data_with_missing_image = build(:edition_world_location_image_data, file: '')
    image_data_with_missing_image.save(validate: false)
    edition = create(:published_world_location_news_article)
    feature = create(:featured_edition_world_location, edition: edition, edition_world_location_image_data_id: image_data_with_missing_image.id)

    new_edition = edition.create_draft(create(:author))
    refute_equal feature.id, EditionWorldLocation.last.id
  end
end
