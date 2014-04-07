require 'test_helper'

class PaginationHelperTest < ActionView::TestCase
  test "next_page_link should build a link inside an li with the given attributes" do
    rendered = Nokogiri::HTML::DocumentFragment.parse(next_page_link(url: '/somewhere?page=2', page: 2, of: 10)).children.first

    assert_equal 'li', rendered.name
    assert_equal 'next', rendered[:class]

    link_tag = rendered.at_css('a')
    assert_equal '/somewhere?page=2', link_tag[:href]
    assert_equal "Next page 2 of 10", link_tag.text
  end

  test "previous_page_link should build a link inside an li with the given attributes" do
    rendered = Nokogiri::HTML::DocumentFragment.parse(previous_page_link(url: '/somewhere?page=2', page: 2, of: 10)).children.first

    assert_equal 'li', rendered.name
    assert_equal 'previous', rendered[:class]

    link_tag = rendered.at_css('a')
    assert_equal '/somewhere?page=2', link_tag[:href]
    assert_equal "Previous page 2 of 10", link_tag.text
  end
end

