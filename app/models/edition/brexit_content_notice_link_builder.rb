module Edition::BrexitContentNoticeLinkBuilder
  MAX_LINKS = 3

  def allows_brexit_content_notice?
    true
  end

  def build_brexit_notice_links
    link_builder(brexit_no_deal_content_notice_links)
    link_builder(brexit_current_state_content_notice_links)
  end

  def link_builder(content_notice_link)
    count = MAX_LINKS - link_counter(content_notice_link)
    count.times do
      content_notice_link.build
    end
  end

  def link_counter(content_notice_link)
    content_notice_link.count do |link|
      link.persisted? || link.new_record?
    end
  end
end
