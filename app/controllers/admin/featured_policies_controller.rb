class Admin::FeaturedPoliciesController < Admin::BaseController
  before_action :load_organisation

  def index
    @featured_policies = @organisation.featured_policies.order(:ordering)
    @policies = Policy.all.sort_by(&:title)
  end

  def create
    featured_policy = @organisation.featured_policies.build(policy_content_id: params[:policy_content_id])
    featured_policy.save!
    redirect_to admin_organisation_featured_policies_path(@organisation), notice: 'Policy featured'
  end

  def destroy
    featured_policy = @organisation.featured_policies.find(params[:id])
    featured_policy.destroy!
    redirect_to admin_organisation_featured_policies_path(@organisation), notice: "'#{featured_policy.title}' unfeatured"
  end

  def reorder
    params[:ordering].each_pair do |featured_policy_id, order|
      FeaturedPolicy.find(featured_policy_id).update_attributes(ordering: order)
    end
    redirect_to admin_organisation_featured_policies_path(@organisation), notice: 'Order updated'
  end

private
  def load_organisation
    @organisation = Organisation.friendly.find(params[:organisation_id])
  end
end
