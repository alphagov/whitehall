require "test_helper"

class SafeHtmlValidatorTest < ActiveSupport::TestCase
  def setup
    Whitehall.stubs(:skip_safe_html_validation).returns(false)
  end

  TestStruct = Struct.new(:bad_content)

  test "it marks HTML-unsafe attributes as such" do
    test_model = build(
      :publication,
      body: '<script>alert("hax!")</script>',
      title: "Safe title",
    )

    SafeHtmlValidator.new({}).validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal ["cannot include invalid formatting or JavaScript"], test_model.errors[:body]
  end

  test "span and div elements are considered safe" do
    test_model = build(
      :publication,
      body: '<div class="govspeak"><span class="number">1</span></div>',
      title: "Safe title",
    )

    SafeHtmlValidator.new({}).validate(test_model)
    assert test_model.errors.empty?, test_model.errors.full_messages.inspect
  end

  test "enumerable attribute values are validated" do
    errors = mock("object")
    error_message = "cannot include invalid formatting or JavaScript"
    errors.expects(:add).with("foo", error_message)
    errors.expects(:add).with("bar", error_message)
    errors.expects(:add).with("baz", error_message)

    test_model = mock("object")
    test_model.expects(:marked_for_destruction?).returns(false)
    test_model.expects(:changes).returns({
      "foo" => [nil, ["<script>alert(\"hax!\")</script>"]],
      "bar" => [nil, { "bad_content" => "<script>alert(\"hax!\")</script>" }],
      "baz" => [nil, TestStruct.new("<script>alert(\"hax!\")</script>")],
    })
    test_model.expects(:errors).times(3).returns(errors)

    SafeHtmlValidator.new({}).validate(test_model)
  end

  test "only applies to specific attributes, when specified" do
    bad_html = '<script>alert("hax!")</script>'
    test_model = build(
      :publication,
      body: bad_html,
      summary: bad_html,
      title: bad_html,
    )

    # only validate body attribute
    SafeHtmlValidator.new(attribute: :body).validate(test_model)
    assert_equal %i[body], test_model.errors.group_by_attribute.keys

    # validate body and title attributes
    SafeHtmlValidator.new(attributes: %i[body title]).validate(test_model)
    assert_equal %i[body title], test_model.errors.group_by_attribute.keys

    # no attributes specified - so validate all changed attributes
    SafeHtmlValidator.new.validate(test_model)
    assert_equal %i[body title summary], test_model.errors.group_by_attribute.keys
  end
end
