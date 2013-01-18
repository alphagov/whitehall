# encoding: utf-8
require "fast_test_helper"

require "whitehall/uploader/parsers/summarise_body"

module Whitehall::Uploader::Parsers
  class SummariseBodyTest < ActiveSupport::TestCase
    test 'converts the body text from govspeak to html' do
      SummariseBody::Govspeaker.expects(:htmlize).with('my-body-text').returns('my body text')
      SummariseBody.parse('my-body-text')
    end

    test 'removes tags from the html version of the body' do
      SummariseBody::Govspeaker.stubs(:htmlize).returns('<h1>Woo</h1>')
      assert_equal 'Woo', SummariseBody.parse('whatevs')
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
    end

    class SanitizerTest < ActiveSupport::TestCase
      test 'uses actionview/base.full_sanitizer to sanitize the html' do
        ::ActionView::Base.full_sanitizer.expects(:sanitize).with('the body text as html').returns('the de-htmlified body text')
        assert_equal 'the de-htmlified body text', Sanitizer.sanitize('the body text as html')
      end
    end
  end
end
