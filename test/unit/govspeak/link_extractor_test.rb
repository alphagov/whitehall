require 'test_helper'

module Govspeak
  class ExtractorTest < ActiveSupport::TestCase
    test "extracts links from govspeak" do
      extractor = LinkExtractor.new(govspeak_with_links)
      expected_links = %w(http://some-link.com http://another-link.com)

      assert_equal expected_links, extractor.call
    end

    test "converts admin edition links to public-facing URLS" do
      speech     = create(:published_speech)
      admin_path = Whitehall.url_maker.admin_speech_path(speech)
      public_url = Whitehall.url_maker.public_document_url(speech)
      extractor  = LinkExtractor.new(govspeak_with_admin_link(admin_path))
      expected_links = ['http://first-link.com', public_url]

      assert_equal expected_links, extractor.call
    end

    test "converts absolute paths to full URLs" do
      extractor = LinkExtractor.new(govspeak_with_paths)
      expected_links = ['http://full.com/url', "#{Whitehall.public_root}/path-only"]

      assert_equal expected_links, extractor.call
    end

    test "ignores mailto links" do
      extractor = LinkExtractor.new("A [mailto](mailto:email@domain.com) and a [link](http://example.com)")
      assert_equal ['http://example.com'], extractor.call
    end

    test "ignores anchor links to sections on the same page" do
      extractor = LinkExtractor.new("[Index](#index) and a [link](http://example.com)")
      assert_equal ['http://example.com'], extractor.call
    end

    test "extracts URLs with anchor links" do
      extractor = LinkExtractor.new("[Index](#index) and a [link](http://example.com#index)")
      assert_equal ['http://example.com#index'], extractor.call
    end

  private

    def govspeak_with_links
      <<-HEREDOC.strip_heredoc
        ## A document

        Here is some HTML with a [link](http://some-link.com)
        or [two](http://another-link.com)
      HEREDOC
    end

    def govspeak_with_admin_link(admin_path)
      <<-HEREDOC.strip_heredoc
        ## A document

        Here is some HTML with a [link](http://first-link.com)
        Here is a link to a [document](#{admin_path})
      HEREDOC
    end

    def govspeak_with_paths
      <<-HEREDOC.strip_heredoc
        ## A document

        Here is some HTML with a [complete URL link](http://full.com/url)
        and also a [relative path](/path-only)
      HEREDOC
    end
  end
end
