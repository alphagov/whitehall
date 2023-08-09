require "test_helper"

class Admin::JavascriptHelperTest < ActionView::TestCase
  include Admin::JavascriptHelper

  test "initialise_script should render a script initialisation to :javascript_initialisers" do
    stubs(:content_for).with do |yield_block, script|
      assert_equal :javascript_initialisers, yield_block
      assert script.include?("GOVUK.init(GOVUK.SomeObject"), "expected #{script} to include 'GOVUK.init(GOVUK.SomeObject'"
    end
    initialise_script "GOVUK.SomeObject"
  end

  test "initialise_script should pass params down to script initialisation as json" do
    stubs(:content_for).with do |_yield_block, script|
      assert script.include?('{"foo":"bar"}'), "expected #{script} to include '{\"foo\":\"bar\"}'"
    end
    initialise_script "GOVUK.SomeObject", foo: "bar"
  end

  test "initialise_script should return a string marked as html_safe" do
    stubs(:content_for).with do |_yield_block, script|
      assert script.html_safe?
    end
    initialise_script "GOVUK.SomeObject"
  end
end
