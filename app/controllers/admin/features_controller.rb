class Admin::FeaturesController < Admin::BaseController
  before_action :find_feature_list
  before_action :build_feature, only: %i[new create]
  before_action :find_edition, :find_topical_event, :find_offsite_link, only: [:new]
  layout :get_layout

  def new
    render_design_system(:new, :legacy_new)
  end

  def create
    if @feature.save
      @feature.republish_featurable_to_publishing_api
      PublishingApiDocumentRepublishingWorker.perform_async(@feature.document_id) if @feature.document_id.present?
      redirect_to admin_feature_list_path(@feature_list), notice: "The document has been saved"
    else
      flash.now[:alert] = "Unable to create feature"
      render_design_system(:new, :legacy_new)
    end
  end

  def confirm_unfeature
    @feature = @feature_list.features.find(params[:id])
  end

  def unfeature
    @feature = @feature_list.features.find(params[:id])

    if @feature.end!
      @feature.republish_featurable_to_publishing_api
      message = { notice: "'#{@feature}' unfeatured" }
    else
      message = { alert: "Unable to unfeature '#{@feature}' because #{@feature.errors.full_messages.to_sentence}" }
    end

    redirect_to admin_feature_list_path(@feature_list), message
  end

private

  def get_layout
    if preview_design_system?(next_release: false)
      "design_system"
    else
      "admin"
    end
  end

  def find_feature_list
    @feature_list = FeatureList.find(params[:feature_list_id])
  end

  def build_feature
    @feature = @feature_list.features.build(feature_params)
  end

  def feature_params
    params.fetch(:feature, {}).permit(
      :image, :image_cache, :alt_text, :document_id, :topical_event_id, :offsite_link_id
    )
  end

  def find_edition
    @feature.document = Edition.find(params[:edition_id]).document if params[:edition_id]
  end

  def find_topical_event
    @feature.topical_event = TopicalEvent.find(params[:topical_event_id]) if params[:topical_event_id]
  end

  def find_offsite_link
    @feature.offsite_link = OffsiteLink.find(params[:offsite_link_id]) if params[:offsite_link_id]
  end
end
