require "test_helper"

module Govspeak
  class LinkRedirectorTest < ActiveSupport::TestCase
    test "refuses to operate on domains shorter than 6 characters long" do
      assert_raises(match: /domain must be at least 6 characters long/) do
        LinkRedirector.new("", "x.com", "https://replacement-url.com/some-path")
      end
    end

    test "refuses to operate on domains which don't include a dot" do
      assert_raises(match: /domain must include a '[.]'/) do
        LinkRedirector.new("", "banana", "https://replacement-url.com/some-path")
      end
    end

    test "refuses to replace domains with URLs that don't start with https" do
      assert_raises(match: /redirect_url must start with https:\/\//) do
        LinkRedirector.new("", "example.com", "example.com/some-path")
      end
    end

    test "match returns false if the markdown does not match the patterns" do
      examples = [
        "Here is some markdown with a link to example.com",
        "Here is some markdown with a link to [example.com](http://www.gov.uk)",
        'Here is some markdown with a link to <a href="www.gov.uk">example.com</a>',
      ]

      examples.each do |govspeak|
        result = LinkRedirector.new(govspeak, "example.com", "https://replacement-url.com/some-path").match?
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
        result = LinkRedirector.new(govspeak, "example.com", "https://replacement-url.com/some-path").match?
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
        - will replace '[a](example.com)' with '[a](https://replacement-url.com/some-path)'
        - will replace '[b](http://example.com)' with '[b](https://replacement-url.com/some-path)'
        - will replace '[c](https://example.com)' with '[c](https://replacement-url.com/some-path)'
        - will replace '[d](https://example.com/some-path)' with '[d](https://replacement-url.com/some-path)'
        - will replace '[e](https://example.com/some-path?some-query)' with '[e](https://replacement-url.com/some-path)'
        - will replace '[f](https://example.com/some-path?some-query#some-search)' with '[f](https://replacement-url.com/some-path)'
      EXPECTED

      result = LinkRedirector.new(govspeak, "example.com", "https://replacement-url.com/some-path").describe_replacements
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

      expected = <<~'EXPECTED'
        - will replace '<a href="example.com">a</a>' with '<a href="https://replacement-url.com/some-path">a</a>'
        - will replace '<a href="http://example.com">b</a>' with '<a href="https://replacement-url.com/some-path">b</a>'
        - will replace '<a href="https://example.com">c</a>' with '<a href="https://replacement-url.com/some-path">c</a>'
        - will replace '<a href="https://example.com/some-path">d</a>' with '<a href="https://replacement-url.com/some-path">d</a>'
        - will replace '<a href="https://example.com/some-path?some-query">e</a>' with '<a href="https://replacement-url.com/some-path">e</a>'
        - will replace '<a href="https://example.com/some-path?some-query#some-search">f</a>' with '<a href="https://replacement-url.com/some-path">f</a>'
      EXPECTED

      result = LinkRedirector.new(html, "example.com", "https://replacement-url.com/some-path").describe_replacements
      assert_equal expected.strip, result
    end

    test "replaces markdown links to provided domain with provided redirect" do
      examples = [
        "Here is some markdown with a link to [example dot com](example.com)",
        "Here is some markdown with a link to [example dot com](http://example.com)",
        "Here is some markdown with a link to [example dot com](https://example.com)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path?some-query)",
        "Here is some markdown with a link to [example dot com](https://example.com/some-path?some-query#some-search)",
      ]

      examples.each do |govspeak|
        result = LinkRedirector.new(govspeak, "example.com", "https://replacement-url.com/some-path").redirect_links_for_domain
        assert_equal "Here is some markdown with a link to [example dot com](https://replacement-url.com/some-path)", result
      end
    end

    test "redirects HTML links to provided domain to provided redirect" do
      examples = [
        {
          input: 'Here is some markdown with a link to <a href="example.com">example dot com</a>',
          expected: 'Here is some markdown with a link to <a href="https://replacement-url.com/some-path">example dot com</a>',
        },
        {
          input: 'Here is some markdown with a link to <a href="http://example.com">example dot com</a>',
          expected: 'Here is some markdown with a link to <a href="https://replacement-url.com/some-path">example dot com</a>',
        },
        {
          input: 'Here is some markdown with a link to <a href="https://example.com" class="govuk-link">example dot com</a>',
          expected: 'Here is some markdown with a link to <a href="https://replacement-url.com/some-path" class="govuk-link">example dot com</a>',
        },
        {
          input: 'Here is some markdown with a link to <a class="govuk-link" href="https://example.com/some-path">example dot com</a>',
          expected: 'Here is some markdown with a link to <a class="govuk-link" href="https://replacement-url.com/some-path">example dot com</a>',
        },
        {
          input: 'Here is some markdown with a link to <a href="https://example.com/some-path?some-query" rel="noreferrer">example dot com</a>',
          expected: 'Here is some markdown with a link to <a href="https://replacement-url.com/some-path" rel="noreferrer">example dot com</a>',
        },
        {
          input: 'Here is some markdown with a link to <a href="https://example.com/some-path?some-query#some-search">example dot com</a>',
          expected: 'Here is some markdown with a link to <a href="https://replacement-url.com/some-path">example dot com</a>',
        },
      ]

      examples.each do |example|
        result = LinkRedirector.new(example[:input], "example.com", "https://replacement-url.com/some-path").redirect_links_for_domain
        assert_equal example[:expected], result
      end
    end

    test "replaces links even in complex markdown" do
      govspeak = <<~GOVSPEAK
        ## A heading containing [a link to the domain we're replacing](https://example.com/some-path)

        | table | with headings             |
        |-------|---------------------------|
        | cells | [with links](example.com) |

        * lists
        * [with links](example.com)
      GOVSPEAK
      result = LinkRedirector.new(govspeak, "example.com", "https://replacement-url.com/some-path").redirect_links_for_domain
      assert_equal <<~EXPECTATION, result
        ## A heading containing [a link to the domain we're replacing](https://replacement-url.com/some-path)

        | table | with headings             |
        |-------|---------------------------|
        | cells | [with links](https://replacement-url.com/some-path) |

        * lists
        * [with links](https://replacement-url.com/some-path)
      EXPECTATION
    end

    test "leaves links to other domains" do
      govspeak = "Here is some markdown with a link to [other-domain dot com](other-domain.com)"
      result = LinkRedirector.new(govspeak, "example.com", "https://replacement-url.com/some-path").redirect_links_for_domain
      assert_equal govspeak, result
    end

    test "leaves links to subdomains" do
      govspeak = "Here is some markdown with a link to [a subdomain of example.com](www.example.com)"
      result = LinkRedirector.new(govspeak, "example.com", "https://replacement-url.com/some-path").redirect_links_for_domain
      assert_equal govspeak, result
    end
  end
end
