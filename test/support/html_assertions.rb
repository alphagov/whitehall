require 'support/css_selectors'

module HtmlAssertions
  include CssSelectors

  def refute_select(selector, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(count: 0)
    args.push(options)
    assert_select selector, *args
  end

  def assert_select_object(object, *args, &block)
    assert_select record_css_selector(object), *args, &block
  end

  def refute_select_object(object)
    assert_select_object object, count: 0
  end

  def assert_select_within_html(html, *args)
    node = ::HTML::Document.new(html).root
    assert_select(node, *args)
  end

  def refute_select_within_html(html, *args)
    node = ::HTML::Document.new(html).root
    refute_select(node, *args)
  end
end
