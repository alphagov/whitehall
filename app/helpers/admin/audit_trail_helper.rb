module Admin::AuditTrailHelper
  def describe_audit_trail_entry(entry)
    actor = entry.actor
    html = if entry.respond_to?(:message)
      content_tag(:span, class: "body") do
        "&ldquo;".html_safe + entry.message + "&rdquo;".html_safe
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
end
