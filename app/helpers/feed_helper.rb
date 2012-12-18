module FeedHelper
  def link_to_feed(feed_url)
    content_tag(:div, class: 'subscribe') do
      link_to "feed", feed_url, class: "feed"
    end
  end

  def document_as_feed_entry(document, builder, govdelivery_version = false)
    document_category = document.format_name.titleize
    if govdelivery_version
      builder.title "#{document_category}: #{document.title}"
    else
      builder.title document.title
    end
    builder.category document_category
    builder.summary document.summary
    if govdelivery_version
      builder.content document.summary, type: 'text'
    else
      builder.content govspeak_edition_to_html(document), type: 'html'
    end
  end

  def feed_wants_govdelivery_version?
    if params[:govdelivery_version].present? && params[:govdelivery_version] =~ /\A(?:true|yes|1|on)\Z/i
      true
    else
      false
    end
  end
end