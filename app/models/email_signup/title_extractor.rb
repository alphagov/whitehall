class EmailSignup::TitleExtractor
  def initialize(alert)
    @alert = alert
  end

  def title
    if @alert.policy
      policy_title_part
    else
      [document_type_title_part, topic_title_part, organisation_title_part, local_government_title_part].compact.join(' ')
    end
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
          t = Classification.find_by_slug(@alert.topic)
          if t.present?
            t.name
          else
            raise EmailSignup::InvalidSlugError.new(@alert.topic, :topic)
          end
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
          o = Organisation.find_by_slug(@alert.organisation)
          if o.present?
            o.name
          else
            raise EmailSignup::InvalidSlugError.new(@alert.organisation, :organisation)
          end
        end
      "by #{title}" if title
    end
  end

  def local_government_title_part
    'relevant to local government' if @alert.info_for_local?
  end

  def policy_title_part
    if @alert.policy
      policy = Policy.published_as(@alert.policy)
      "All alerts related to policy #{policy.title}" if policy
    end
  end
end
