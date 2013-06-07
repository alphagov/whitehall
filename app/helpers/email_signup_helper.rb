module EmailSignupHelper
  def document_type_options_for_email_signup(selected_option = nil)
    options = {
      'Publications' => @document_types[:publication_type].map { |pt| [pt.label, "publication_type_#{pt.slug}"] },
      'Announcements' => @document_types[:announcement_type].map { |at| [at.label, "announcement_type_#{at.slug}"] },
      'Policies' => @document_types[:policy_type].map { |pt| [pt.label, "policy_type_#{pt.slug}"] }
    }
    options_for_select([['all types of document', 'all']], selected_option) +
    grouped_options_for_select(options, selected_option)
  end

  def topic_options_for_email_signup(selected_option = nil)
    topic_options = [
      [ 'Topics', @classifications[:topic].map { |o| [o.name, o.slug] } ],
      [ 'Topical events', @classifications[:topical_event].map { |o| [o.name, o.slug] } ]
    ]

    options_for_select([['any topic or topical event', 'all']], selected_option) +
    grouped_options_for_select(topic_options, selected_option)
  end

  def organisation_options_for_email_signup(selected_option = nil)
    options = {
      'Ministerial departments' => @live_ministerial_departments.map { |o| [o.name, o.slug] },
      'Other departments & public bodies' => @live_other_departments.map { |o| [o.name, o.slug] }
    }

    options_for_select([['all organisations', 'all']], selected_option) +
    grouped_options_for_select(options, selected_option)
  end

  def policy_title_for_email_signup(slug)
    if policy = Policy.published_as(slug)
      policy.title
    end
  end
end
