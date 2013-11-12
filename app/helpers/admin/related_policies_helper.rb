module Admin::RelatedPoliciesHelper
  def options_from_related_policy_options_for_select(related_policy_options, edition)
    selected_policy_ids = edition.related_policy_ids
    selected_policy_ids |= Array(params[:edition][:related_policy_ids]) if params[:edition]

    options_from_collection_for_select(related_policy_options, :first, :last, selected_policy_ids)
  end
end
