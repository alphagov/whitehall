class Admin::PromotionalFeatureItemsController < Admin::BaseController
  before_action :load_organisation
  before_action :load_promotional_feature
  before_action :load_promotional_feature_item, only: %i[edit update destroy confirm_destroy]
  before_action :clean_image_or_youtube_video_url_param, only: %i[create update]
  layout "design_system"

  def new
    @promotional_feature_item = @promotional_feature.promotional_feature_items.build
    @promotional_feature_item.links.build
  end

  def create
    @promotional_feature_item = @promotional_feature.promotional_feature_items.build(promotional_feature_item_params)
    @promotional_feature_item.use_non_legacy_endpoints = use_non_legacy_endpoints?
    if @promotional_feature_item.save
      Whitehall::PublishingApi.republish_async(@organisation)
      redirect_to_feature "Feature item added."
    else
      @promotional_feature_item.links.build if @promotional_feature_item.links.blank?
      render :new
    end
  end

  def edit
    @promotional_feature_item.links.build if @promotional_feature_item.links.empty?
  end

  def update
    legacy_image_url = @promotional_feature_item.image.file&.instance_variable_get("@legacy_url_path")

    if @promotional_feature_item.update(promotional_feature_item_params)
      Whitehall::PublishingApi.republish_async(@organisation)
      if legacy_image_url.present?
        current_legacy_image_url = @promotional_feature_item.image.file&.instance_variable_get("@legacy_url_path")
        AssetManager::AssetDeleter.call(legacy_image_url, nil) if legacy_image_url != current_legacy_image_url
      end

      redirect_to_feature "Feature item updated."
    else
      @promotional_feature_item.links.build if @promotional_feature_item.links.blank?
      render :edit
    end
  end

  def destroy
    @promotional_feature_item.destroy!
    Whitehall::PublishingApi.republish_async(@organisation)
    redirect_to_feature "Feature item deleted."
  end

  def confirm_destroy; end

private

  def load_organisation
    @organisation = Organisation.allowed_promotional.find(params[:organisation_id])
  end

  def load_promotional_feature
    @promotional_feature = @organisation.promotional_features.find(params[:promotional_feature_id])
  end

  def load_promotional_feature_item
    @promotional_feature_item = @promotional_feature.promotional_feature_items.find(params[:id])
  end

  def redirect_to_feature(notice = nil)
    redirect_to [:admin, @organisation, @promotional_feature], notice:
  end

  def promotional_feature_item_params
    @promotional_feature_item_params ||= params.require(:promotional_feature_item).permit(
      :summary,
      :image,
      :image_alt_text,
      :title,
      :title_url,
      :image_cache,
      :youtube_video_url,
      :youtube_video_alt_text,
      :image_or_youtube_video_url,
      links_attributes: %i[url text _destroy id],
    )
  end

  def clean_image_or_youtube_video_url_param
    feature_item_type = promotional_feature_item_params.delete(:image_or_youtube_video_url)

    if feature_item_type == "youtube_video_url"
      promotional_feature_item_params["image"] = nil
      promotional_feature_item_params["image_alt_text"] = nil
    else
      promotional_feature_item_params["youtube_video_url"] = nil
      promotional_feature_item_params["youtube_video_alt_text"] = nil
    end
  end
end
