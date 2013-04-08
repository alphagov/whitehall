module EmailSignupHelper
  def document_type_options_for_email_signup(selected_option = nil)
    options = {
      'Publications' => [ ['all publication types', 'publication_type_all' ] ] + publication_types_for_filter.sort_by{ |a| a.label }.map{ |pt| [pt.label, "publication_type_#{pt.slug}"] },
      'Announcements' => [ ['all announcment types', 'announcement_type_all' ] ] + announcement_types_for_filter.sort_by{ |a| a.label }.map{ |at| [at.label, "announcement_type_#{at.slug}"] },
      'Policies' => [ ['all policies', 'policy_type_all' ] ]
    }
    options_for_select([['all types of document', 'all']], selected_option) +
    grouped_options_for_select(options, selected_option)
  end

  def topic_options_for_email_signup(selected_option = nil)
    options_for_select([['any topic', 'all']] + @classifications.map { |o| [o.name, o.slug] }, selected_option)
  end

  def organisation_options_for_email_signup(selected_option = nil)
    options = {
      'Ministerial departments' => @live_ministerial_departments.map { |o| [o.name, o.slug] },
      'Other departments &amp; public bodies' => @live_other_departments.map { |o| [o.name, o.slug] }
    }

    options_for_select([['all organisations', 'all']], selected_option) +
    grouped_options_for_select(options, selected_option)
  end
end
