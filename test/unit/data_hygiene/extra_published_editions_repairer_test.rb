require 'test_helper'
require 'data_hygiene/extra_published_editions_repairer'

module Whitehall
  class ExtraPublishedEditionsRepairerTest < ActiveSupport::TestCase
    setup do
      @logger = stub_everything("Logger")
      @repairer = DataHygiene::ExtraPublishedEditionsRepairer.new(@logger)
    end

    test 'includes a document if it has more than one published edition' do
      d1 = create(:published_edition, :with_document).document
      d2 = create(:published_edition, :with_document).document
      d3 = create(:published_edition, :with_document).document
      d4 = create(:published_edition, :with_document).document
      create(:draft_edition, document: d1).update_column(:state, 'published')
      publish(create(:draft_edition, document: d3))
      create(:draft_edition, document: d4)

      docs_to_be_repaired = @repairer.documents
      assert docs_to_be_repaired.include?(d1), "expected doc with > 1 published edition to be present"
      refute docs_to_be_repaired.include?(d2), "expected doc with just one published edition not to be present"
      refute docs_to_be_repaired.include?(d3), "expected doc with 1 published edition (and 1 superseded edition) not to be present"
      refute docs_to_be_repaired.include?(d4), "expected doc with 1 published edition (and 1 draft edition) not to be present"
    end

    test 'fetches the newest (by id) published edition for a given document' do
      e1 = create(:published_edition, :with_document)
      d = e1.document
      e2 = create(:draft_edition, document: d); e2.update_column(:state, 'published')
      e3 = create(:draft_edition, document: d); e3.update_column(:state, 'published')
      e4 = create(:draft_edition, document: d)

      assert_equal e3, @repairer.most_recent_published_edition_for_document(d)
    end

    test 'supersedes all the other published editions for each document' do
      e1 = create(:published_edition, :with_document)
      d1 = e1.document
      e2 = create(:published_edition, :with_document)
      d2 = e2.document

      @repairer.stubs(:documents).returns [d2, d1]
      @repairer.stubs(:most_recent_published_edition_for_document).with(d1).returns e1
      @repairer.stubs(:most_recent_published_edition_for_document).with(d2).returns e2

      e1.expects(:supersede_previous_editions!)
      e2.expects(:supersede_previous_editions!)

      @repairer.repair!
    end

    test 'happily continues through the list of documents if archiving explodes for a given document' do
      e1 = create(:published_edition, :with_document)
      d1 = e1.document
      e2 = create(:published_edition, :with_document)
      d2 = e2.document

      @repairer.stubs(:documents).returns [d2, d1]
      @repairer.stubs(:most_recent_published_edition_for_document).with(d1).returns e1
      @repairer.stubs(:most_recent_published_edition_for_document).with(d2).returns e2

      e1.expects(:supersede_previous_editions!)
      e2.expects(:supersede_previous_editions!).raises("Problem!")

      assert_nothing_raised do
        @repairer.repair!
      end
    end
  end
end
