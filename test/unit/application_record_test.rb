require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "append_url_options adds locale" do
    assert_equal "/government/foo.cy", Edition.new.append_url_options("/government/foo", locale: "cy")
  end

  test "append_url_options adds format" do
    assert_equal "/government/foo.atom", Edition.new.append_url_options("/government/foo", format: "atom")
  end

  test "append_url_options adds locale and format when both present" do
    assert_equal "/government/foo.cy.atom", Edition.new.append_url_options("/government/foo", format: "atom", locale: "cy")
  end

  test "append_url_options adds cachebust string when present" do
    assert_equal "/government/foo?cachebust=123", Edition.new.append_url_options("/government/foo", cachebust: "123")
  end

  test "append_url_options adds anchor string when present" do
    assert_equal "/government/foo#heading", Edition.new.append_url_options("/government/foo", anchor: "heading")
  end

  test "append_url_options adds cachebust string, format, locale and anchor when all present" do
    assert_equal "/government/foo.cy.atom?cachebust=123#heading", Edition.new.append_url_options("/government/foo", cachebust: "123", format: "atom", locale: "cy", anchor: "heading")
  end
end
