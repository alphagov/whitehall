module PaginationHelper
  def next_page_link(url: nil, page: nil, of: nil)
    link_content = "Next <span class=\"visuallyhidden\">page</span> <span class=\"page-numbers\">#{page} of #{of}</span>".html_safe

    content_tag :li, class: 'next' do
      link_to link_content, url
    end
  end

  def previous_page_link(url: nil, page: nil, of: nil)
    link_content = "Previous <span class=\"visuallyhidden\">page</span> <span class=\"page-numbers\">#{page} of #{of}</span>".html_safe

    content_tag :li, class: 'previous' do
      link_to link_content, url
    end
  end
end
