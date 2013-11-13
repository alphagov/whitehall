require "fast_test_helper"

class Edition::GovspeakLinkValidatorTest < ActiveSupport::TestCase

  test "should be valid if it contains a correct absolute URL" do
    validator = DataHygiene::GovspeakLinkValidator.new("
      [example text](http://www.example.com/example)
      [example text](https://www.gov.uk/example)
    ")

    assert_equal [], validator.errors
  end

  test "should be invalid if it contains a malformed absolute URL" do
    validator = DataHygiene::GovspeakLinkValidator.new("
      [example text](www.example.com/example)
      [example text](http:/www.example.com/example)
    ")

    assert_equal 2, validator.errors.count
  end

  test "should be invalid if it contains a correct absolute URL containing 'whitehall-admin'" do
    validator = DataHygiene::GovspeakLinkValidator.new("[example text](https://www.whitehall-admin.gov.uk/example)")
    assert_equal 1, validator.errors.count
  end

  test "should be valid if it contains a proper admin absolute path" do
    validator = DataHygiene::GovspeakLinkValidator.new("
      [example text](/government/admin/policies/12345)
      [example text](/government/admin/editions/12345)
    ")

    assert_equal [], validator.errors
  end

  test "should be invalid if it contains a proper admin relative path" do
    validator = DataHygiene::GovspeakLinkValidator.new("[example text](government/admin/policies/12345)")
    assert_equal 1, validator.errors.count
  end

  test "should be invalid if it contains a non-admin absolute path" do
    validator = DataHygiene::GovspeakLinkValidator.new("[example text](/government/policies)")
    assert_equal 1, validator.errors.count
  end

  test "should identify internal admin links" do
    assert DataHygiene::GovspeakLinkValidator.is_internal_admin_link?([Whitehall.router_prefix, "admin", "test"].join("/"))
    refute DataHygiene::GovspeakLinkValidator.is_internal_admin_link?('http://www.google.com/')
    refute DataHygiene::GovspeakLinkValidator.is_internal_admin_link?(nil)
  end

  test "should permit mailto links" do
    validator = DataHygiene::GovspeakLinkValidator.new("[example text](mailto:test@example.com)")
    assert_equal [], validator.errors
  end

  test "should permit anchor links" do
    validator = DataHygiene::GovspeakLinkValidator.new("[example text](#example-section)")
    assert_equal [], validator.errors
  end

end
