class EmailSignup::FeedUrlExtractor
  include Rails.application.routes.url_helpers
  default_url_options.merge!(host: Whitehall.public_host, protocol: Whitehall.public_protocol)

  def initialize(alert)
    @alert = alert
  end

  def feed_url
    send("#{path_segment_name}_url", filters.merge(format: 'atom'))
  end

  def filters
    filters = {}
    if @alert.organisation && @alert.organisation != 'all'
      filters[:departments] = [@alert.organisation]
    end
    if @alert.topic && @alert.topic != 'all'
      filters[:topics] = [@alert.topic]
    end
    if @alert.document_specific_type != 'all'
      case @alert.document_generic_type
      when 'publication'
        filters[:publication_filter_option] = @alert.document_specific_type
      when 'announcement'
        filters[:announcement_filter_option] = @alert.document_specific_type
      end
    end
    filters
  end

  def path_segment_name
    case @alert.document_generic_type
    when 'publication'
      :publications
    when 'announcement'
      :announcements
    when 'policy'
      :policies
    when 'all'
      :atom_feed
    end
  end
end
