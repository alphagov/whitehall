require 'test_helper'
require 'data_hygiene/tag_changes_processor'
require "gds_api/panopticon"
require 'gds_api/test_helpers/panopticon'

class TopicChangesProcessorTest < ActiveSupport::TestCase
  include DataHygiene
  include GdsApi::TestHelpers::Panopticon

  setup do
    @published_edition = create(:published_publication)
    @draft_edition = create(:draft_publication)
    @published_edition2 = create(:published_publication)
    @draft_edition2 = create(:draft_publication)

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
    panopticon_request = stub_artefact_registration(
      registerable.slug,
      hash_including(specialist_sectors: sectors),
      true
    )
    Whitehall::SearchIndex.expects(:add).with(edition)
    panopticon_request
  end

  test "#process - processes the csv file containing new and old topics" do
    tag_changes_file =  Rails.root.join('test', 'fixtures', 'data_hygiene', 'tag_changes.csv')
    old_tag_1 = 'oil-and-gas/offshore'
    new_tag_1 = 'oil-and-gas/really-far-out'
    old_tag_2 = 'oil-and-gas/inshore'
    new_tag_2 = 'oil-and-gas/on-the-beach'

    create(:specialist_sector, tag: old_tag_1, edition: @draft_edition)
    create(:specialist_sector, tag: old_tag_1, edition: @published_edition)
    create(:specialist_sector, tag: old_tag_2, edition: @draft_edition2)
    create(:specialist_sector, tag: old_tag_2, edition: @published_edition2)

    panopticon_request = stub_registration(@published_edition, [new_tag_1])
    panopticon_request2 = stub_registration(@published_edition2, [new_tag_2])

    PublishingApiWorker.expects(:perform_async).with(@published_edition.class.name, @published_edition.id, update_type: :republish).once
    PublishingApiWorker.expects(:perform_async).with(@published_edition2.class.name, @published_edition2.id, update_type: :republish).once

    processor = TagChangesProcessor.new(tag_changes_file)

    stub_logging(processor)
    processor.process

    assert_requested panopticon_request
    [@published_edition, @draft_edition].each do |edition|
      edition.reload
      assert edition.editorial_remarks.any?
      assert edition.specialist_sectors.map(&:tag) == [new_tag_1]
    end
    assert_requested panopticon_request2
    [@published_edition2, @draft_edition2].each do |edition|
      edition.reload
      assert edition.editorial_remarks.any?
      assert edition.specialist_sectors.map(&:tag) == [new_tag_2]
    end

    expected_logs = [
      %{Updating 2 taggings of editions (1 published) to change #{old_tag_1} to #{new_tag_1}},
      %{tagging '#{@draft_edition.title}' edition #{@draft_edition.id}},
      %{ - adding editorial remark},
      %{tagging '#{@published_edition.title}' edition #{@published_edition.id}},
      %{ - adding editorial remark},
      %{registering '#{@published_edition.title}'},
      %{Updating 2 taggings of editions (1 published) to change #{old_tag_2} to #{new_tag_2}},
      %{tagging '#{@draft_edition2.title}' edition #{@draft_edition2.id}},
      %{ - adding editorial remark},
      %{tagging '#{@published_edition2.title}' edition #{@published_edition2.id}},
      %{ - adding editorial remark},
      %{registering '#{@published_edition2.title}'},
    ]

    assert processor.logs == expected_logs
  end

end
