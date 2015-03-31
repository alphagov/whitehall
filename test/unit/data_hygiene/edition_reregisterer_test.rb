require 'test_helper'
require 'gds_api/test_helpers/panopticon'

module DataHygiene
  class EditionReregistererTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Panopticon

    test "raises error if edition is in draft" do
      assert_raises RuntimeError do
        EditionReregisterer.new(draft_edition).call
      end
    end

    test "registers with panopticon" do
      panopticon_registerer.expects(:register).with(RegisterableEdition.new(published_edition))
      Whitehall.stubs(:panopticon_registerer_for).returns(panopticon_registerer)

      EditionReregisterer.new(published_edition).call
    end

    test "republishes edition to publishing api" do
      Whitehall.stubs(:panopticon_registerer_for).returns(panopticon_registerer)
      Whitehall::PublishingApi.expects(:republish).with(published_edition)

      EditionReregisterer.new(published_edition).call
    end

    def panopticon_registerer
      @panopticon_registerer ||= stub("panopticon_registerer", register: true)
    end

    def draft_edition
      @draft_edition ||= FactoryGirl.create(:draft_edition)
    end

    def published_edition
      @published_edition ||= FactoryGirl.create(:published_edition)
    end
  end
end
