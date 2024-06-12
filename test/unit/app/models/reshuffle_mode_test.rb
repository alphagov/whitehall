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
end
