require 'support/css_selectors'
require 'equivalent-xml'

module HtmlAssertions
  include CssSelectors

  def refute_select(selector, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(count: 0)
    args.push(options)
    assert_select selector, *args
  end

  def assert_select_object(object, *args, &block)
    object = object.kind_of?(Attachment) ? object.becomes(Attachment) : object
    assert_select record_css_selector(object), *args, &block
  end

  def assert_select_prefix_object(object, prefix = nil, *args, &block)
    assert_select record_css_selector(object, prefix), *args, &block
  end

  def refute_select_object(object)
    assert_select_object object, count: 0
  end

  def refute_select_prefix_object(object, prefix = nil)
    assert_select_prefix_object object, prefix, count: 0
  end

  def assert_select_within_html(html, *args, &block)
    node = ::HTML::Document.new(CGI.unescape(html)).root
    assert_select(node, *args, &block)
  end

  def refute_select_within_html(html, *args)
    node = ::HTML::Document.new(CGI.unescape(html)).root
    refute_select(node, *args)
  end

  def assert_equivalent_html(expected, actual)
    assert_block("Expected\n#{actual}\n\nto equal\n\n#{expected}") do
      EquivalentXml.equivalent?(expected, actual)
    end
  end
end
