require 'test_helper'
require 'data_hygiene/tag_changes_processor'
require "gds_api/panopticon"
require 'gds_api/test_helpers/panopticon'
require 'data_hygiene/tag_changes_exporter'

class TopicChangesProcessorTest < ActiveSupport::TestCase
  include DataHygiene
  include GdsApi::TestHelpers::Panopticon

  setup do
    @csv_file = Tempfile.new('tag_changes')
    @published_edition = create(:published_publication)
    @draft_edition = create(:draft_publication)
    @published_edition2 = create(:published_publication)
    @draft_edition2 = create(:draft_publication)
    @old_tag = 'oil-and-gas/offshore'
    @new_tag = 'oil-and-gas/really-far-out'
    @gds_user = create(:gds_team_user)
  end

  def tear_down
    @csv_file.unlink
  end

  def stub_registration(edition, sectors)
    registerable = RegisterableEdition.new(edition)
    stub_artefact_registration(
      registerable.slug,
      hash_including(specialist_sectors: sectors),
      true
    )
  end

  def publishing_worker_expects(editions)
    editions.each do |edition|
      Whitehall::PublishingApi.expects(:republish_async).with(edition).once
    end
  end

  def assert_edition_retagging(editions)
    editions.each do |edition|
      edition.reload
      assert edition.editorial_remarks.any?
      assert edition.specialist_sectors.map(&:tag) == [@new_tag]
    end
  end

  test "#process - processes the csv file containing new and old topics" do
    create(:specialist_sector, tag: @old_tag, edition: @draft_edition)
    create(:specialist_sector, tag: @old_tag, edition: @published_edition)
    create(:specialist_sector, tag: @old_tag, edition: @draft_edition2)
    create(:specialist_sector, tag: @old_tag, edition: @published_edition2)

    TagChangesExporter.new(@csv_file.path, 'oil-and-gas/offshore', 'oil-and-gas/really-far-out').export

    panopticon_published_edition = stub_registration(@published_edition, [@new_tag])
    panopticon_published_edition2 = stub_registration(@published_edition2, [@new_tag])
    panopticon_draft_edition = stub_registration(@draft_edition, [@new_tag])
    panopticon_draft_edition2 = stub_registration(@draft_edition2, [@new_tag])

    publishing_worker_expects([@published_edition, @published_edition2, @draft_edition, @draft_edition2])

    processor = TagChangesProcessor.new(@csv_file.path)

    processor.process

    assert_requested panopticon_published_edition
    assert_requested panopticon_published_edition2
    assert_requested panopticon_draft_edition
    assert_requested panopticon_draft_edition2

    assert_edition_retagging([@published_edition, @published_edition2, @draft_edition, @draft_edition2])
  end
end
