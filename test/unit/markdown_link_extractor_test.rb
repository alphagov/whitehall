require 'test_helper'

class MarkdownLinkExtractorTest < ActiveSupport::TestCase
  test "extracts links from Markdown" do
    extractor = MarkdownLinkExtractor.new(markdown_with_links)

    expected_links = %w(http://some-link.com http://another-link.com)
    assert_equal expected_links, extractor.links
  end

private

  def markdown_with_links
    <<-HEREDOC.strip_heredoc
      ## A document

      Here is some HTML with a [link](http://some-link.com)
      or [two](http://another-link.com)
    HEREDOC
  end
end
