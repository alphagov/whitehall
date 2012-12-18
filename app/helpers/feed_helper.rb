module FeedHelper
  def link_to_feed(feed_url)
    content_tag(:div, class: 'subscribe') do
      link_to "feed", feed_url, class: "feed"
    end
  end

  def document_as_feed_entry(document, builder, summaries_only = false)
    builder.title document.title
    builder.category document.format_name.titleize
    builder.summary document.summary
    if summaries_only
      builder.content document.summary, type: 'text'
    else
      builder.content govspeak_edition_to_html(document), type: 'html'
    end
  end

  def feed_wants_summaries_only?
    if params[:summaries_only].present? && params[:summaries_only] =~ /\A(?:true|yes|1|on)\Z/i
      true
    else
      false
    end
  end
end