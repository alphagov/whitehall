module Admin::RelatedPoliciesHelper
  def related_policy_options_for_select(edition)
    selected_policy_ids = edition.related_policy_ids
    selected_policy_ids |= Array(params[:edition][:related_policy_ids]) if params[:edition]

    options_for_select(cached_related_policy_options, selected_policy_ids)
  end
end
