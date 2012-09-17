module FeedHelper
  def link_to_feed(feed_url)
    content_tag(:div, class: 'subscribe') do
      link_to "feed", feed_url, class: "feed"
    end
  end
end