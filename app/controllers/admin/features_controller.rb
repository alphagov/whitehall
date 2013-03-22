class Admin::FeaturesController < Admin::BaseController
  before_filter :find_feature_list
  before_filter :build_feature
  before_filter :find_edition, only: [:new]

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
    @feature.ended_at = Time.zone.now
    if @feature.save
      message = {notice: "'#{@feature}' unfeatured"}
    else
      message = {error: "Unable to unfeature '#{@feature}' because #{@feature.errors.full_messages.to_sentence}"}
    end
    redirect_to admin_feature_list_path(@feature_list), message
  end

private
  def find_feature_list
    @feature_list = FeatureList.find(params[:feature_list_id])
  end

  def build_feature
    @feature = @feature_list.features.build(params[:feature])
  end

  def find_edition
    @feature.document = @feature_list.featurable_editions.find(params[:edition_id]).document
  end

end
