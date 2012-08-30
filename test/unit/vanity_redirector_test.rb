require "test_helper"

class VanityRedirectorTest < ActiveSupport::TestCase
  setup do
    @redirector = VanityRedirector.new(Rails.root.join("test", "fixtures", "vanity-redirects.csv"))
  end

  test "should redirect bis" do
    expected = "/government/organisations/department-for-business-innovation-and-skills"
    assert_equal expected, @redirector["/bis"]
  end

  test "should enumerate known redirections" do
    expected = %w[ /bis /business /cabinetoffice /dclg ]
    assert_equal expected, @redirector.each.to_a.map(&:first)
  end

  test "should enumerate from and to" do
    expected = %w[ /bis /government/organisations/department-for-business-innovation-and-skills ]
    assert_equal expected, @redirector.first
  end
end
