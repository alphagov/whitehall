module FeedHelper

  def atom_feed_url_for(resource)
    if resource.is_a?(Policy)
      Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol, format: 'atom').activity_policy_url(resource.slug)
    else
      Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol, format: 'atom').url_for(resource)
    end
  end

  def documents_as_feed_entries(documents, builder, feed_updated_timestamp = Time.current)
    govdelivery_version = feed_wants_govdelivery_version?
    feed_updated_timestamp =
      if documents.any?
        documents.first.public_timestamp
      else
        feed_updated_timestamp
      end
    builder.updated feed_updated_timestamp

    documents.each do |document|
      builder.entry(document, id: document_id(document, builder), url: public_document_url(document), published: document.first_public_at, updated: document.public_timestamp) do |entry|
        document_as_feed_entry(document, builder, govdelivery_version)
      end
    end
  end

  def document_id(record, builder)
    # This slightly clunky logic is to give entries a consistent ID -
    # the default `record.id` is the latest edition, which means the
    # entries would get a new ID for each version, which breaks the
    # spec.
    # The interpolation logic is straight out of:
    # http://api.rubyonrails.org/classes/ActionView/Helpers/AtomFeedHelper/AtomFeedBuilder.html#method-i-entry
    id = record.document ? record.document.id : record.id
    "tag:#{host},#{schema_date(builder)}:#{record.class}/#{id}"
  end

  def schema_date(builder)
    builder.instance_variable_get(:@feed_options)[:schema_date]
  end

  def host
    request.host
  end

  def feed_display_type_for(document)
    return "News story" if (document.is_a?(WorldLocationNewsArticle))
    return "Priority" if (document.is_a?(WorldwidePriority))
    document.display_type
  end

  def document_as_feed_entry(document, builder, govdelivery_version = false)
    builder.title "#{feed_display_type_for(document)}: #{document.title}"
    builder.category label: document.display_type, term: document.display_type
    builder.summary entry_summary(document, govdelivery_version)
    builder.content entry_content(document), type: 'html'
  end

  def entry_summary(document, govdelivery_version = false)
    if govdelivery_version
      change_note = document.most_recent_change_note
      change_note = "[Updated: #{change_note}] " if change_note
      "#{change_note}#{document.summary}"
    else
      document.summary
    end
  end

  def entry_content(document)
    change_note = document.most_recent_change_note
    change_note = "<p><em>Updated:</em> #{change_note}</p>" if change_note
    "#{change_note}#{govspeak_edition_to_html(document)}"
  end

  def feed_wants_govdelivery_version?
    if params[:govdelivery_version].present? && params[:govdelivery_version] =~ /\A(?:true|yes|1|on)\Z/i
      true
    else
      false
    end
  end
end
