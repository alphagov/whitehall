module Admin::AuditTrailHelper
  def describe_audit_trail_entry(entry)
    actor = entry.actor
    html = if entry.respond_to?(:message)
             tag.span(class: "body") do
               entry.message
             end
           else
             tag.span(entry.action.capitalize, class: "action") + " by" # rubocop:disable Style/StringConcatenation
           end
    html << " ".html_safe
    html << if actor
              tag.span(class: "actor") { linked_author(actor) }
            else
              "User (removed)"
            end
    html << " ".html_safe
    html << absolute_time(entry.created_at, class: "created_at")
  end

  def paginated_audit_trail_url(page)
    url_for(
      params.to_unsafe_hash
            .merge(controller: "admin/edition_audit_trail", action: "index", page: (page <= 1 ? nil : page))
            .symbolize_keys,
    )
  end

  def render_editorial_remarks(paginated_remarks, edition)
    grouped_remarks = paginated_remarks.query.group_by do |remark|
      if remark.edition_id > edition.id
        "On newer editions"
      elsif remark.edition_id < edition.id
        "On previous editions"
      else
        "On this edition"
      end
    end

    html = grouped_remarks.map do |heading, remarks|
      h2 = tag.h2(heading, class: "add-top-margin")
      ul = tag.ul(class: "list-unstyled") do
        render partial: "admin/editions/remark_entry", collection: remarks, as: :remark
      end
      h2 + ul
    end

    html.join.html_safe
  end
end
