require 'test_helper'

class JavascriptHelperTest < ActionView::TestCase
  include JavascriptHelper

  test "initialise_script should render a script initialisation to :javascript_initialisers" do
    self.stubs(:content_for).with() {|yield_block, script|
      assert_equal :javascript_initialisers, yield_block
      assert script.include?("GOVUK.init(GOVUK.SomeObject"), "expected #{script} to include 'GOVUK.init(GOVUK.SomeObject'"
    }
    initialise_script "GOVUK.SomeObject"
  end

  test "initialise_script should pass params down to script initialisation as json" do
    self.stubs(:content_for).with() {|yield_block, script|
      assert script.include?('{"foo":"bar"}'), "expected #{script} to include '{\"foo\":\"bar\"}'"
    }
    initialise_script "GOVUK.SomeObject", foo: "bar"
  end

  test "initialise_script should return a string marked as html_safe" do
    self.stubs(:content_for).with() {|yield_block, script|
      assert script.html_safe?
    }
    initialise_script "GOVUK.SomeObject"
  end
end
