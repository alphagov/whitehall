module Admin::SupportingPagesHelper
  def related_policy_links(supporting_page)
    supporting_page.related_policies.map do |policy|
      url = if supporting_page.published?
        public_document_path(supporting_page, policy_id: policy.document)
      else
        preview_document_path(supporting_page, policy_id: policy.document)
      end

      [url, "View with policy: #{policy.title}"]
    end
  end
end
