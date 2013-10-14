module Admin::AuditTrailHelper
  def describe_audit_trail_entry(entry)
    actor = entry.actor
    html = if entry.respond_to?(:message)
      content_tag(:span, class: "body") do
        entry.message.html_safe
      end
    else
      content_tag(:span, entry.action.capitalize, class: "action") + " by"
    end
    html << " ".html_safe
    if actor
      html << content_tag(:span, class: "actor") { linked_author(actor) }
    else
      html << "User (removed)"
    end
    html << " ".html_safe
    html << absolute_time(entry.created_at, class: "created_at")
  end

  def paginated_audit_trail_url(page)
    url_for(params.merge(controller: 'admin/edition_audit_trail', action: 'index', page: ((page <= 1) ? nil : page)))
  end

  def render_editorial_remarks_in_sidebar(remarks, edition)
    this_edition_remarks, other_edition_remarks = remarks.partition { |r| r.edition == edition }
    out = ''
    if this_edition_remarks.any?
      out << content_tag(:h2, 'On this edition')
      out << content_tag(:ul) do
        render partial: "admin/editions/audit_trail_entry", collection: this_edition_remarks
      end
    end
    if other_edition_remarks.any?
      out << content_tag(:h2, 'On previous editions')
      out << content_tag(:ul) do
        render partial: "admin/editions/audit_trail_entry", collection: other_edition_remarks
      end
    end
    out.html_safe
  end
end
