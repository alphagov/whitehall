require "test_helper"

class GovspeakLinkValidatorTest < ActiveSupport::TestCase
  test "should be valid if the input is nil" do
    test_model = Edition.new(body: nil)

    GovspeakLinkValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
    assert_equal [], test_model.errors[:body]
  end

  test "should be invalid if it contains a correct absolute URL containing 'whitehall-admin'" do
    test_model = Edition.new(body: "[example text](https://www.whitehall-admin.gov.uk/example)")

    GovspeakLinkValidator.new.validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal ["Issue with link `https://www.whitehall-admin.gov.uk/example`: This links to the whitehall-admin domain. Please use paths, eg /government/admin/publications/3373, for documents created in publisher (see guidance on creating links) or full URLs for other GOV.UK links."], test_model.errors.map(&:type)
  end

  test "should be valid if it contains a proper admin absolute path" do
    test_model = Edition.new(body: "
      [example text](/government/admin/policies/12345)
      [example text](/government/admin/editions/12345)
    ")

    GovspeakLinkValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
  end

  test "should be invalid if it contains a proper admin relative path" do
    test_model = Edition.new(body: "[example text](government/admin/policies/12345)")
    GovspeakLinkValidator.new.validate(test_model)
    assert_equal 1, test_model.errors.size
    assert_equal ["Issue with link `government/admin/policies/12345`: This is an invalid admin link.  Did you mean /government/admin/policies/12345 instead of government/admin/policies/12345?"], test_model.errors.map(&:type)
  end

  test "should identify internal admin links" do
    assert GovspeakLinkValidator.is_internal_admin_link?([Whitehall.router_prefix, "admin", "test"].join("/"))
    assert_not GovspeakLinkValidator.is_internal_admin_link?("http://www.google.com/")
    assert_not GovspeakLinkValidator.is_internal_admin_link?(nil)
  end
end
