class EmailSignup::TitleExtractor
  def initialize(alert)
    @alert = alert
  end

  def title
    [document_type_title_part, topic_title_part, organisation_title_part].compact.join(' ')
  end

  def document_type_title_part
    if @alert.document_specific_type == 'all'
      case @alert.document_generic_type
      when 'all'
        'All types of document'
      when 'publication'
        'All publications'
      when 'announcement'
        'All announcements'
      when 'policy'
        'All policies'
      end
    else
      if @alert.document_generic_type == 'publication'
        Whitehall::PublicationFilterOption.find_by_slug(@alert.document_specific_type).label
      elsif @alert.document_generic_type == 'announcement'
        Whitehall::AnnouncementFilterOption.find_by_slug(@alert.document_specific_type).label
      end
    end
  end

  def topic_title_part
    if @alert.topic
      title =
        if @alert.topic == 'all'
          'all topics'
        else
          Topic.find_by_slug(@alert.topic).try(:name)
        end
      "about #{title}" if title
    end
  end

  def organisation_title_part
    if @alert.organisation
      title =
        if @alert.organisation == 'all'
          'all organisations'
        else
          Organisation.find_by_slug(@alert.organisation).try(:name)
        end
      "by #{title}" if title
    end
  end
end
