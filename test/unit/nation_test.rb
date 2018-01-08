require "test_helper"

class NationTest < ActiveSupport::TestCase
  test "England is never inapplicable" do
    refute Nation.potentially_inapplicable.include?(Nation.england)
  end
end
