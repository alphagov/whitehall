require "test_helper"

module Govspeak
  class LinkRemoverTest < ActiveSupport::TestCase
    test "refuses to operate on domains shorter than 6 characters long" do
      assert_raises(match: /domain must be at least 6 characters long/) do
        LinkRemover.new("", "x.com")
      end
    end

    test "refuses to operate on domains which don't include a dot" do
      assert_raises(match: /domain must include a '[.]'/) do
        LinkRemover.new("", "banana")
      end
    end

    test "match returns false if the markdown does not match the patterns" do
      examples = [
        "Here is some markdown with a link to example.com",
        "Here is some markdown with a link to [example.com](http://www.gov.uk)",
        'Here is some markdown with a link to <a href="www.gov.uk">example.com</a>',
      ]

      examples.each do |govspeak|
        result = LinkRemover.new(govspeak, "example.com").match?
        assert_equal false, result
      end
    end

    test "match returns true if the markdown does match the patterns" do
      examples = [
        "Here is some markdown with a link to [example dot com](example.com)",
        "Here is some markdown with a link to [example dot com](http://example.com)",
        "Here is some markdown with a link to [example dot com](https://example.com)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path?some-query)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path?some-query#some-search)",
      ]

      examples.each do |govspeak|
        result = LinkRemover.new(govspeak, "example.com").match?
        assert_equal true, result
      end
    end

    test "describes markdown replacements" do
      govspeak = <<~GOVSPEAK
        Here is some markdown with a link to [a](example.com),
        Here is some markdown with a link to [b](http://example.com),
        Here is some markdown with a link to [c](https://example.com),
        Here is some markdown with a link to [d](https://example.com/some-path),
        Here is some markdown with a link to [e](https://example.com/some-path?some-query),
        Here is some markdown with a link to [f](https://example.com/some-path?some-query#some-search),
      GOVSPEAK

      expected = <<~EXPECTED
        - will replace '[a](example.com)' with 'a'
        - will replace '[b](http://example.com)' with 'b'
        - will replace '[c](https://example.com)' with 'c'
        - will replace '[d](https://example.com/some-path)' with 'd'
        - will replace '[e](https://example.com/some-path?some-query)' with 'e'
        - will replace '[f](https://example.com/some-path?some-query#some-search)' with 'f'
      EXPECTED

      result = LinkRemover.new(govspeak, "example.com").describe_replacements
      assert_equal expected.strip, result
    end

    test "describes HTML replacements" do
      html = <<~HTML
        Here is some HTML with a link to <a href="example.com">a</a>
        Here is some HTML with a link to <a href="http://example.com">b</a>
        Here is some HTML with a link to <a href="https://example.com">c</a>
        Here is some HTML with a link to <a href="https://example.com/some-path">d</a>
        Here is some HTML with a link to <a href="https://example.com/some-path?some-query">e</a>
        Here is some HTML with a link to <a href="https://example.com/some-path?some-query#some-search">f</a>
      HTML

      expected = <<~EXPECTED
        - will replace '<a href="example.com">a</a>' with 'a'
        - will replace '<a href="http://example.com">b</a>' with 'b'
        - will replace '<a href="https://example.com">c</a>' with 'c'
        - will replace '<a href="https://example.com/some-path">d</a>' with 'd'
        - will replace '<a href="https://example.com/some-path?some-query">e</a>' with 'e'
        - will replace '<a href="https://example.com/some-path?some-query#some-search">f</a>' with 'f'
      EXPECTED

      result = LinkRemover.new(html, "example.com").describe_replacements
      assert_equal expected.strip, result
    end

    test "removes markdown links to provided domain" do
      examples = [
        "Here is some markdown with a link to [example dot com](example.com)",
        "Here is some markdown with a link to [example dot com](http://example.com)",
        "Here is some markdown with a link to [example dot com](https://example.com)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path?some-query)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path?some-query#some-search)",
      ]

      examples.each do |govspeak|
        result = LinkRemover.new(govspeak, "example.com").remove_links_for_domain
        assert_equal "Here is some markdown with a link to example dot com", result
      end
    end

    test "removes HTML links to provided domain" do
      examples = [
        'Here is some HTML with a link to <a href="example.com">example dot com</a>',
        'Here is some HTML with a link to <a href="http://example.com">example dot com</a>',
        'Here is some HTML with a link to <a href="https://example.com" class="govuk-link">example dot com</a>',
        'Here is some HTML with a link to <a class="govuk-link" href="https://example.com/some-path">example dot com</a>',
        'Here is some HTML with a link to <a href="https://example.com/some-path?some-query" rel="noreferrer">example dot com</a>',
        'Here is some HTML with a link to <a href="https://example.com/some-path?some-query#some-search">example dot com</a>',
      ]

      examples.each do |govspeak|
        result = LinkRemover.new(govspeak, "example.com").remove_links_for_domain
        assert_equal "Here is some HTML with a link to example dot com", result
      end
    end

    test "removes links even in complex markdown" do
      govspeak = <<~GOVSPEAK
        ## A heading containing [a link to the domain we're removing](https://example.com/some-path)

        | table | with headings             |
        |-------|---------------------------|
        | cells | [with links](example.com) |

        * lists
        * [with links](example.com)
      GOVSPEAK
      result = LinkRemover.new(govspeak, "example.com").remove_links_for_domain
      assert_equal <<~EXPECTATION, result
        ## A heading containing a link to the domain we're removing

        | table | with headings             |
        |-------|---------------------------|
        | cells | with links |

        * lists
        * with links
      EXPECTATION
    end

    test "leaves links to other domains" do
      govspeak = "Here is some markdown with a link to [other-domain dot com](other-domain.com)"
      result = LinkRemover.new(govspeak, "example.com").remove_links_for_domain
      assert_equal govspeak, result
    end

    test "leaves links to subdomains" do
      govspeak = "Here is some markdown with a link to [a subdomain of example.com](www.example.com)"
      result = LinkRemover.new(govspeak, "example.com").remove_links_for_domain
      assert_equal govspeak, result
    end
  end
end
