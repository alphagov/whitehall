module Admin::SupportingPagesHelper
  def related_policy_links(supporting_page)
    supporting_page.related_policies.map do |policy|
      href = if supporting_page.published? || supporting_page.archived?
        public_document_url(supporting_page, policy_id: policy.document)
      else
        preview_document_path(supporting_page, policy_id: policy.document)
      end

      [href, "View with policy: #{policy.title}"]
    end
  end
end
