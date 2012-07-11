module HtmlAssertions
  def assert_select_within_html(html, *args)
    node = HTML::Document.new(html).root
    assert_select(node, *args)
  end
end
