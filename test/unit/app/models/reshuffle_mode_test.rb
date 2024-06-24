require "test_helper"

class ReshuffleModeTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  class ClassThatIncludesReshuffleMode < ApplicationRecord
    self.table_name = "organisations"
    include ReshuffleMode
  end

  describe "#reshuffle_in_progress?" do
    it "returns false when reshuffle mode is switched off" do
      assert_not ClassThatIncludesReshuffleMode.new.reshuffle_in_progress?
    end

    it "returns true when reshuffle mode is switched on" do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

      assert ClassThatIncludesReshuffleMode.new.reshuffle_in_progress?
    end
  end

  describe "#patch_links_ministers_index_page_to_publishing_api" do
    it "patches links on the 'Ministers Index' page" do
      PatchLinksPublishingApiWorker.expects(:perform_async).with("PublishingApi::MinistersIndexPresenter").once

      ClassThatIncludesReshuffleMode.new.patch_links_ministers_index_page_to_publishing_api
    end
  end

  describe "#republish_how_government_works_page_to_publishing_api" do
    it "republishes the 'How Government Works' page" do
      PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HowGovernmentWorksPresenter").once

      ClassThatIncludesReshuffleMode.new.republish_how_government_works_page_to_publishing_api
    end

    it "publishes the 'reshuffle presenter' version when reshuffle mode is on" do
      PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HowGovernmentWorksEnableReshufflePresenter").once

      reshuffle_mode = ClassThatIncludesReshuffleMode.new
      reshuffle_mode.stubs(:reshuffle_in_progress?).returns(true)
      reshuffle_mode.republish_how_government_works_page_to_publishing_api
    end
  end
end
