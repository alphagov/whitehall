class EmailSignup::FeedUrlExtractor
  def self.url_maker
    @url_maker ||= Whitehall::UrlMaker.new(host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end
  def url_maker
    self.class.url_maker
  end

  def initialize(alert)
    @alert = alert
  end

  def feed_url
    if @alert.policy
      url_maker.activity_policy_url(@alert.policy, format: :atom)
    else
      url_maker.send("#{path_segment_name}_url", filters.merge(format: 'atom'))
    end
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
    if @alert.info_for_local?
      filters[:relevant_to_local_government] = 1
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
