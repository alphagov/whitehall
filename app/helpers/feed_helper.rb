module FeedHelper
  def link_to_feed(feed_url)
    link_to "feed", feed_url, class: "feed"
  end

  def documents_as_feed_entries(documents, builder, govdelivery_version = false, feed_updated_timestamp = Time.current)
    feed_updated_timestamp =
      if documents.any?
        documents.first.public_timestamp
      else
        feed_updated_timestamp
      end
    builder.updated feed_updated_timestamp

    documents.each do |document|
      builder.entry(document, url: public_document_url(document), published: document.first_public_at, updated: document.public_timestamp) do |entry|
        document_as_feed_entry(document, builder, govdelivery_version)
      end
    end
  end

  def document_as_feed_entry(document, builder, govdelivery_version = false)
    document_category = document.display_type
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
