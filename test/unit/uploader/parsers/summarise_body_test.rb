# encoding: utf-8
require "fast_test_helper"

require "whitehall/uploader/parsers/summarise_body"

module Whitehall::Uploader::Parsers
  class SummariseBodyTest < ActiveSupport::TestCase
    test 'can cope with being provided a nil body' do
      assert_nothing_raised do
        SummariseBody.parse(nil)
      end
    end

    test 'converts the body text from govspeak to html' do
      SummariseBody::Govspeaker.expects(:htmlize).with('my-body-text').returns('my body text')
      SummariseBody.parse('my-body-text')
    end

    test 'removes tags and entities from the html version of the body' do
      SummariseBody::Govspeaker.stubs(:htmlize).returns('<h1>&ldquo;Woo&rdquo;&#33;</h1>')
      assert_equal '“Woo”!', SummariseBody.parse('whatevs')
    end

    test 'if the de-tagged version of the body is > the supplied size it is truncated with elipsis' do
      SummariseBody::Sanitizer.stubs(:sanitize).returns('1234567890 ENDS. This should be TRUNCATED')
      truncated = '1234567890 ENDS.…'
      assert_equal truncated, SummariseBody.parse('whatevs', 16)
    end

    test 'if the de-tagged version of the body is > the supplied size and the size-th char is in the middle of a word it is truncated after that word' do
      SummariseBody::Sanitizer.stubs(:sanitize).returns('1234567890 ENDINGS. This should be TRUNCATED')
      truncated = '1234567890 ENDINGS…'
      assert_equal truncated, SummariseBody.parse('whatevs', 16)
    end

    test 'it truncates coping with utf-8 chars in words' do
      SummariseBody::Sanitizer.stubs(:sanitize).returns('1234567890 ENDIÑGß. This should be TRUNCATED')
      truncated = '1234567890 ENDIÑGß…'
      assert_equal truncated, SummariseBody.parse('whatevs', 16)
    end
  end

  class SummariseBody
    class GovspeakerTest < ActiveSupport::TestCase
      test 'creates a govspeak document and asks it for html' do
        govspoken = mock
        govspoken.responds_like(::Govspeak::Document.new(''))
        govspoken.expects(:to_html).returns('the body text as html')
        ::Govspeak::Document.expects(:new).with('the body text').returns(govspoken)
        assert_equal 'the body text as html', Govspeaker.htmlize('the body text')
      end

      test 'will remove any attachment references from the govspeak' do
        assert_equal "<p>the body text without attachments </p>\n", Govspeaker.htmlize('!@1 !@2 the body text !@4without attachments [InlineAttachment:3]')
      end
    end

    class SanitizerTest < ActiveSupport::TestCase
      test 'uses actionview/base.full_sanitizer to strip out the html tags' do
        ::ActionView::Base.full_sanitizer.expects(:sanitize).with('the body text as html').returns('the de-htmlified body text')
        assert_equal 'the de-htmlified body text', Sanitizer.sanitize('the body text as html')
      end

      test 'uses htmlentities to remove html entities from the html-tag stripped text' do
        ::ActionView::Base.full_sanitizer.stubs(:sanitize).returns('the de-htmlified body text')
        ::HTMLEntities.any_instance.expects(:decode).with('the de-htmlified body text').returns('the de-html-entityified body text')
        assert_equal 'the de-html-entityified body text', Sanitizer.sanitize('the body text as html')
      end
    end
  end
end
