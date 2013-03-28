class Admin::FeaturedTopicsAndPoliciesListsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :fetch_featured_topics_and_policies_list

  def show
  end

  def update
    if @featured_topics_and_policies_list.update_attributes(params[:featured_topics_and_policies_list])
      redirect_to admin_organisation_featured_topics_and_policies_list_path(@organisation), notice: "Featured topics and policies for #{@organisation.name} updated"
    else
      render :show
    end
  end

  private
  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def fetch_featured_topics_and_policies_list
    @featured_topics_and_policies_list = @organisation.featured_topics_and_policies_list || @organisation.build_featured_topics_and_policies_list
  end
end
