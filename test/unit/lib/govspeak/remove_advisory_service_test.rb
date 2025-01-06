require "test_helper"

class Govspeak::RemoveAdvisoryServiceTest < ActiveSupport::TestCase
  test "advisory_match_group matches if the line begins with an @, and ends with a carriage return" do
    body = "\r\n@ New online safety legislation is coming which will aim to reduce online harms.\r\n\r\n"
    edition = create(:published_edition, body:)

    expected = {
      opening_at: "@",
      content_after_at: " New online safety legislation is coming which will aim to reduce online harms.",
      closing_at: "",
      other_possible_line_ends: nil,
    }
    service = Govspeak::RemoveAdvisoryService.new(edition)
    assert_equal expected, service.advisory_match_group(body)
  end

  test "advisory_match_group matches if the line begins with an @, and ends with an @" do
    body = "\r\n@ New online safety legislation is coming which will aim to reduce online harms.@\r\n\r\n"
    edition = create(:published_edition, body:)

    expected = {
      opening_at: "@",
      content_after_at: " New online safety legislation is coming which will aim to reduce online harms.",
      closing_at: "@",
      other_possible_line_ends: nil,
    }
    service = Govspeak::RemoveAdvisoryService.new(edition)
    assert_equal expected, service.advisory_match_group(body)
  end

  test "replace_all_advisories can replace a single advisory" do
    body = "\r\n@ New online safety legislation is coming which will aim to reduce online harms.@\r\n\r\n"
    edition = create(:published_edition, body:)
    service = Govspeak::RemoveAdvisoryService.new(edition)

    expected = "\r\n^ New online safety legislation is coming which will aim to reduce online harms.^\r\n\r\n"

    assert_equal expected, service.replace_all_advisories(edition.body)
  end

  test "replace_all_advisories can replace multiple advisories" do
    body = "\r\n@ New online safety legislation is coming which will aim to reduce online harms.@\r\n\r\n@ And here's another. @\r\n\r\n"
    edition = create(:published_edition, body:)
    service = Govspeak::RemoveAdvisoryService.new(edition)

    expected = "\r\n^ New online safety legislation is coming which will aim to reduce online harms.^\r\n\r\n^ And here's another. ^\r\n\r\n"

    assert_equal expected, service.replace_all_advisories(edition.body)
  end

  test "replace_all_advisories will replace advisories with no space after the @" do
    body = "@This is a very important message or warning@"
    edition = create(:published_edition, body:)
    service = Govspeak::RemoveAdvisoryService.new(edition)

    expected = "^This is a very important message or warning^"

    assert_equal expected, service.replace_all_advisories(edition.body)
  end

  test "replace_all_advisories will replace advisories with no closing @" do
    body = "\r\n@ New online safety legislation is coming which will aim to reduce online harms.\r\n\r\n"
    edition = create(:published_edition, body:)
    service = Govspeak::RemoveAdvisoryService.new(edition)

    expected = "\r\n^ New online safety legislation is coming which will aim to reduce online harms.^\r\n\r\n"

    assert_equal expected, service.replace_all_advisories(edition.body)
  end

  test "replace_all_advisories will not replace anything resembling an email address" do
    body = "\r\nFor further information please get in touch at contact@foobar.com.\r\n\r\n"
    edition = create(:published_edition, body:)
    service = Govspeak::RemoveAdvisoryService.new(edition)

    expected = "\r\nFor further information please get in touch at contact@foobar.com.\r\n\r\n"

    assert_equal expected, service.replace_all_advisories(edition.body)
  end

  test "replace_all_advisories will not replace twitter handles" do
    # NB any instances of twitter handles at the start of a line have been handled separately
    body = "\r\nTo hear more you can follow us at on @foobar\r\n\r\n"
    edition = create(:published_edition, body:)
    service = Govspeak::RemoveAdvisoryService.new(edition)

    expected = "\r\nTo hear more you can follow us at on @foobar\r\n\r\n"

    assert_equal expected, service.replace_all_advisories(edition.body)
  end
end
