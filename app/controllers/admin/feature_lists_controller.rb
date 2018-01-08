class Admin::FeatureListsController < Admin::BaseController
  before_action :find_feature_list

  def show
    redirect_to feature_list_path(@feature_list)
  end

  def reorder
    new_order = (params[:ordering] || []).sort_by { |_k, v| v.to_i }.map(&:first)
    if @feature_list.reorder!(new_order)
      message = { notice: "Feature order updated" }
    else
      message = { alert: "Unable to reorder features because #{@feature_list.errors.full_messages.to_sentence}" }
    end
    redirect_to feature_list_path(@feature_list), message
  end

private

  def find_feature_list
    @feature_list = FeatureList.find(params[:id] || params[:feature_list_id])
  end

  def feature_list_path(feature_list)
    polymorphic_url([:features, :admin, feature_list.featurable], locale: feature_list.locale)
  end
end
