class Admin::FeatureListsController < Admin::BaseController
  before_filter :find_feature_list

  def show
    redirect_to feature_list_path(@feature_list)
  end

  def reorder
    new_order = params[:ordering].sort_by {|k,v| v.to_i}.map(&:first)
    if @feature_list.reorder!(new_order)
      redirect_to feature_list_path(@feature_list), notice: "Feature order updated"
    else
      raise @feature_list.errors.full_messages.to_sentence
    end
  end

private
  def find_feature_list
    @feature_list = FeatureList.find(params[:id] || params[:feature_list_id])
  end

  def feature_list_path(feature_list)
    polymorphic_url([:admin, feature_list.featurable, :features], locale: feature_list.locale)
  end
end
