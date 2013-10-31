module Admin::SupportingPagesHelper
  def preview_url(policy, supporting_page, options = {preview: false})
    if options[:preview]
      policy_supporting_page_path(policy.document, supporting_page.document, preview: supporting_page.id, cachebust: Time.zone.now.getutc.to_i)
    else
      policy_supporting_page_path(policy.document, supporting_page.document)
    end
  end

  def related_policy_links(supporting_page)
    supporting_page.related_policies.map do |policy|
      [preview_url(policy, supporting_page, preview: !supporting_page.published?), policy.title]
    end
  end
end
