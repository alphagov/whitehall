require 'test_helper'
require 'data_hygiene/tag_changes_processor'
require "gds_api/panopticon"
require 'gds_api/test_helpers/panopticon'
require 'data_hygiene/tag_changes_exporter'

class TopicChangesProcessorTest < ActiveSupport::TestCase
  include DataHygiene
  include GdsApi::TestHelpers::Panopticon

  setup do
    @published_edition = create(:published_publication)
    @draft_edition = create(:draft_publication)
    @published_edition2 = create(:published_publication)
    @draft_edition2 = create(:draft_publication)
    @old_tag = 'oil-and-gas/offshore'
    @new_tag = 'oil-and-gas/really-far-out'
    @gds_user = create(:user, email: 'govuk-whitehall@digital.cabinet-office.gov.uk')
  end

  # Replace the `log` method on a TopicTagger with one that appends the logged
  # messages to an array.  Return the array.
  def stub_logging(processor)
    def processor.log(message)
      @logs ||= []
      @logs << message
    end
    def processor.logs
      @logs
    end
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
      PublishingApiWorker.expects(:perform_async).with(edition.class.name, edition.id, 'republish').once
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
    tag_changes_file =  Rails.root.join('test', 'fixtures', 'data_hygiene', 'tag_changes.csv')

    create(:specialist_sector, tag: @old_tag, edition: @draft_edition)
    create(:specialist_sector, tag: @old_tag, edition: @published_edition)
    create(:specialist_sector, tag: @old_tag, edition: @draft_edition2)
    create(:specialist_sector, tag: @old_tag, edition: @published_edition2)

    TagChangesExporter.new(tag_changes_file, 'oil-and-gas/offshore', 'oil-and-gas/really-far-out').export

    panopticon_published_edition = stub_registration(@published_edition, [@new_tag])
    panopticon_published_edition2 = stub_registration(@published_edition2, [@new_tag])
    panopticon_draft_edition = stub_registration(@draft_edition, [@new_tag])
    panopticon_draft_edition2 = stub_registration(@draft_edition2, [@new_tag])

    publishing_worker_expects([@published_edition, @published_edition2, @draft_edition, @draft_edition2])

    processor = TagChangesProcessor.new(tag_changes_file)

    stub_logging(processor)
    processor.process

    assert_requested panopticon_published_edition
    assert_requested panopticon_published_edition2
    assert_requested panopticon_draft_edition
    assert_requested panopticon_draft_edition2

    assert_edition_retagging([@published_edition, @published_edition2, @draft_edition, @draft_edition2])

    expected_logs = [
      %{Updating 1 taggings to change #{@old_tag} to #{@new_tag}},
      %{tagging '#{@published_edition.title}' edition #{@published_edition.id}},
      %{ - adding editorial remark},
      %{registering '#{@published_edition.title}'},
      %{Updating 1 taggings to change #{@old_tag} to #{@new_tag}},
      %{tagging '#{@draft_edition.title}' edition #{@draft_edition.id}},
      %{ - adding editorial remark},
      %{registering '#{@draft_edition.title}'},
      %{Updating 1 taggings to change #{@old_tag} to #{@new_tag}},
      %{tagging '#{@published_edition2.title}' edition #{@published_edition2.id}},
      %{ - adding editorial remark},
      %{registering '#{@published_edition2.title}'},
      %{Updating 1 taggings to change #{@old_tag} to #{@new_tag}},
      %{tagging '#{@draft_edition2.title}' edition #{@draft_edition2.id}},
      %{ - adding editorial remark},
      %{registering '#{@draft_edition2.title}'},
    ]
    assert processor.logs == expected_logs
  end

end
