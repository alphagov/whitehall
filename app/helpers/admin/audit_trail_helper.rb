module Admin::AuditTrailHelper
  def describe_audit_trail_entry(entry)
    actor = entry.actor
    html = if entry.respond_to?(:message)
      content_tag(:span, class: "body") do
        "&ldquo;".html_safe + entry.message + "&rdquo;".html_safe
      end
    else
      verb = make_past_tense(entry.event).capitalize
      content_tag(:span, verb, class: "action") + " by"
    end
    html << " ".html_safe
    if actor
      html << content_tag(:span, class: "actor") { linked_author(actor) }
    else
      html << "User (removed)"
    end
    html << " ".html_safe
    html << relative_time(entry.created_at, class: "created_at")
  end

  def make_past_tense(verb_in_present_tense)
    suffix = case verb_in_present_tense
    when /[aeiou]t$/ then 'ted'
    when /e$/ then 'd'
    else 'ed'
    end
    verb_in_present_tense + suffix
  end

  def ends_in_t?(word)
    word[-1] == 't'
  end
end
