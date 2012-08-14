module PolicyHelper
  def part_of_policy_paragraph(policies)
    if policies and policies.any?
      content_tag :p, "Part of ".html_safe + list_of_links_to_policies(policies) + ".".html_safe, class: 'policies js-hide-other-links'
    end
  end

  def list_of_links_to_policies(policies)
    policies.map { |policy| link_to policy.title, public_document_path(policy), class: "policy", id: "policy_#{policy.id}" }.to_sentence.html_safe
  end
end
