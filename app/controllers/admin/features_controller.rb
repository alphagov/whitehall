class Admin::FeaturesController < Admin::BaseController
  before_filter :find_feature_list
  before_filter :build_feature
  before_filter :find_edition, :find_topical_event, only: [:new]

  def new
  end

  def create
    if @feature.save
      redirect_to admin_feature_list_path(@feature_list), notice: "The document has been saved"
    else
      flash.now[:alert] = "Unable to create feature"
      render action: "new"
    end
  end

  def unfeature
    @feature = @feature_list.features.find(params[:id])
    if @feature.end!
      message = {notice: "'#{@feature}' unfeatured"}
    else
      message = {alert: "Unable to unfeature '#{@feature}' because #{@feature.errors.full_messages.to_sentence}"}
    end
    redirect_to admin_feature_list_path(@feature_list), message
  end

private
  def find_feature_list
    @feature_list = FeatureList.find(params[:feature_list_id])
  end

  def build_feature
    @feature = @feature_list.features.build(feature_params)
  end

  def feature_params
    params.fetch(:feature, {}).permit(
      :image, :image_cache, :alt_text, :document_id, :topical_event_id
    )
  end

  def find_edition
    @feature.document = Edition.find(params[:edition_id]).document if params[:edition_id]
  end

  def find_topical_event
    @feature.topical_event = TopicalEvent.find(params[:topical_event_id]) if params[:topical_event_id]
  end

end
