require "test_helper"

class GovspeakLinkValidatorTest < ActiveSupport::TestCase
  test "should be valid if the input is nil" do
    test_model = Edition.new(body: nil)

    GovspeakLinkValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
    assert_equal [], test_model.errors[:body]
  end

  test "should be valid if it contains a correct absolute URL" do
    test_model = Edition.new(body: "
      [example text](http://www.example.com/example)
      [example text](https://www.gov.uk/example)
    ")

    GovspeakLinkValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
    assert_equal [], test_model.errors[:body]
  end

  test "should be invalid if it contains a malformed absolute URL" do
    test_model = Edition.new(body: "
      [example text](www.example.com/example)
      [example text](http:/www.example.com/example)
    ")

    GovspeakLinkValidator.new.validate(test_model)

    assert_equal 2, test_model.errors.size
    assert_equal [
      "Issue with link `www.example.com/example`: Non-document or external links should start with http://, https://, mailto:, or # (for linking to sections on the same page, eg #actions on a policy)",
      "Issue with link `http:/www.example.com/example`: Non-document or external links should start with http://, https://, mailto:, or # (for linking to sections on the same page, eg #actions on a policy)",
    ], test_model.errors.map(&:type)
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

  test "should be invalid if it contains a non-admin absolute path" do
    test_model = Edition.new(body: "[example text](/government/policies)")
    GovspeakLinkValidator.new.validate(test_model)
    assert_equal 1, test_model.errors.size
    assert_equal ["Issue with link `/government/policies`: If you are linking to a document created within Whitehall publisher, please use the internal admin path, e.g. /government/admin/publications/3373. If you are linking to other GOV.UK links, please use full URLs."], test_model.errors.map(&:type)
  end

  test "should identify internal admin links" do
    assert GovspeakLinkValidator.is_internal_admin_link?([Whitehall.router_prefix, "admin", "test"].join("/"))
    assert_not GovspeakLinkValidator.is_internal_admin_link?("http://www.google.com/")
    assert_not GovspeakLinkValidator.is_internal_admin_link?(nil)
  end

  test "should permit mailto links" do
    test_model = Edition.new(body: "[example text](mailto:test@example.com)")
    GovspeakLinkValidator.new.validate(test_model)
    assert_equal 0, test_model.errors.size
  end

  test "should permit anchor links" do
    test_model = Edition.new(body: "[example text](#example-section)")
    GovspeakLinkValidator.new.validate(test_model)
    assert_equal 0, test_model.errors.size
  end
end
