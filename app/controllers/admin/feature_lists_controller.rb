class Admin::FeatureListsController < Admin::BaseController
  before_action :find_feature_list

  def show
    redirect_to feature_list_path(@feature_list)
  end

  def reorder
    new_order = ordering_params.to_h.sort_by { |_k, v| v.to_i }.map(&:first)
    message = if @feature_list.reorder!(new_order)
                { notice: "Feature order updated" }
              else
                { alert: "Unable to reorder features because #{@feature_list.errors.full_messages.to_sentence}" }
              end
    redirect_to feature_list_path(@feature_list), message
  end

private

  def ordering_params
    # keys in ordering should be the ids of objects so that means they should be
    # integers, we can't permit them based on an allow list, but we can pick
    # only those keys that are integers and permit the whole param object after
    # that
    params.fetch(:ordering, {}).select { |k, _v| k =~ /\A\d+\Z/ }.permit!
  end

  def find_feature_list
    @feature_list = FeatureList.find(params[:id] || params[:feature_list_id])
  end

  def feature_list_path(feature_list)
    polymorphic_url([:features, :admin, feature_list.featurable], locale: feature_list.locale)
  end
end
