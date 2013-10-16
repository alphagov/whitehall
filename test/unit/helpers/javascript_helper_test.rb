require 'test_helper'

class JavascriptHelperTest < ActionView::TestCase
  include JavascriptHelper

  test "initialise_script should render a script initialisation to :javascript_initialisers" do
    self.stubs(:content_for).with() {|yield_block, script|
      assert_equal :javascript_initialisers, yield_block
      assert script.include?("Whitehall.init(Whitehall.SomeObject"), "expected #{script} to include 'Whitehall.init(Whitehall.SomeObject'"
    }
    initialise_script "Whitehall.SomeObject"
  end

  test "initialise_script should pass params down to script initialisation as json" do
    self.stubs(:content_for).with() {|yield_block, script|
      assert script.include?('{"foo":"bar"}'), "expected #{script} to include '{\"foo\":\"bar\"}'"
    }
    initialise_script "Whitehall.SomeObject", foo: "bar"
  end
end
