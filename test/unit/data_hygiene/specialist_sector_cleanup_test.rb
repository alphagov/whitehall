require 'test_helper'
require 'data_hygiene/specialist_sector_cleanup'

class SpecialistSectorCleanupTest < ActiveSupport::TestCase
  include DataHygiene

  setup do
    @published_edition = create(:published_edition)
    @draft_edition = create(:draft_edition)
    @gds_user = create(:user, email: 'govuk-whitehall@digital.cabinet-office.gov.uk')
    @tag_slug = 'oil-and-gas/offshore'
  end

  test "#any_taggings? is true if any content is tagged to the sector" do
    cleanup = SpecialistSectorCleanup.new(@tag_slug)
    refute cleanup.any_taggings?

    create(:specialist_sector, tag: @tag_slug, edition: @published_edition)
    assert cleanup.any_taggings?
  end

  test "#remove_taggings handles deleted editions, without adding notes" do
    deleted_edition = create(:deleted_edition)
    create(:specialist_sector, tag: @tag_slug, edition: deleted_edition)

    SpecialistSectorCleanup.new(@tag_slug).remove_taggings

    assert_equal 0, SpecialistSector.count
    assert_equal 0, EditorialRemark.count
    fail
  end

  test "#remove_taggings removes the taggings without adding notes" do
    create(:specialist_sector, tag: @tag_slug, edition: @draft_edition)
    create(:specialist_sector, tag: @tag_slug, edition: @published_edition)

    SpecialistSectorCleanup.new(@tag_slug).remove_taggings

    assert_equal 0, SpecialistSector.count
    assert_equal 0, EditorialRemark.count
  end

  test "#remove_taggings(add_note: true) removes the taggings and adds notes" do
    create(:specialist_sector, tag: @tag_slug, edition: @draft_edition)
    create(:specialist_sector, tag: @tag_slug, edition: @published_edition)

    SpecialistSectorCleanup.new(@tag_slug).remove_taggings

    assert_equal 0, SpecialistSector.count

    [@published_edition, @draft_edition].each do |edition|
      edition.reload
      assert edition.editorial_remarks.any?
    end
  end
end
