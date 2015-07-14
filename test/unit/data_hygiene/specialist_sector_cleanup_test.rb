require 'test_helper'
require 'data_hygiene/specialist_sector_cleanup'

class SpecialistSectorCleanupTest < ActiveSupport::TestCase
  include DataHygiene

  setup do
    @published_edition = create(:published_edition)
    @draft_edition = create(:draft_edition)
    @gds_user = create(:gds_team_user)
  end

  test "#any_taggings? is true if any content is tagged to the sector" do
    cleanup = SpecialistSectorCleanup.new('oil-and-gas/offshore')
    refute cleanup.any_taggings?

    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @published_edition)
    assert cleanup.any_taggings?
  end

  test "#any_published_taggings? is true if any published content is tagged to the sector" do
    cleanup = SpecialistSectorCleanup.new('oil-and-gas/offshore')
    refute cleanup.any_published_taggings?

    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @draft_edition)
    refute cleanup.any_published_taggings?

    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @published_edition)
    assert cleanup.any_published_taggings?
  end

  test "#any_published_taggings? handles orphaned taggings" do
    cleanup = SpecialistSectorCleanup.new('oil-and-gas/offshore')

    tagging = create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @draft_edition)
    tagging.update_column(:edition_id, 12345)
    refute cleanup.any_published_taggings?

    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @published_edition)
    assert cleanup.any_published_taggings?
  end

  test "#remove_taggings(add_note: false) removes the taggings without adding notes" do
    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @draft_edition)
    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @published_edition)

    SpecialistSectorCleanup.new('oil-and-gas/offshore').remove_taggings(add_note: false)

    assert_equal 0, SpecialistSector.count
    assert_equal 0, EditorialRemark.count
  end

  test "#remove_taggings handles orphaned taggings" do
    tagging = create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @draft_edition)
    tagging.update_column(:edition_id, 12345)
    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @published_edition)

    SpecialistSectorCleanup.new('oil-and-gas/offshore').remove_taggings

    assert_equal 0, SpecialistSector.count
    #assert_equal 0, EditorialRemark.count
  end

  test "#remove_taggings(add_note: true) removes the taggings and adds notes" do
    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @draft_edition)
    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @published_edition)

    SpecialistSectorCleanup.new('oil-and-gas/offshore').remove_taggings(add_note: true)

    assert_equal 0, SpecialistSector.count

    [@published_edition, @draft_edition].each do |edition|
      edition.reload
      assert edition.editorial_remarks.any?
    end
  end
end
