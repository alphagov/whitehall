class Admin::PromotionalFeaturesController < Admin::BaseController
  before_action :load_organisation
  before_action :load_promotional_feature, only: %i[show edit update destroy]
  before_action :clean_image_or_youtube_video_url_param, only: %i[create]
  layout :get_layout

  def index
    @promotional_features = @organisation.promotional_features
  end

  def new
    @promotional_feature = @organisation.promotional_features.build
    @promotional_feature.promotional_feature_items.build
    @promotional_feature.promotional_feature_items.first.links.build
  end

  def create
    @promotional_feature = @organisation.promotional_features.build(promotional_feature_params)
    if @promotional_feature.save
      Whitehall::PublishingApi.republish_async(@organisation)
      redirect_to [:admin, @organisation, @promotional_feature], notice: "Promotional feature created"
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @promotional_feature.update(promotional_feature_params)
      Whitehall::PublishingApi.republish_async(@organisation)
      redirect_to [:admin, @organisation, @promotional_feature], notice: "Promotional feature updated"
    else
      render action: :edit
    end
  end

  def destroy
    @promotional_feature.destroy!
    Whitehall::PublishingApi.republish_async(@organisation)
    redirect_to [:admin, @organisation, PromotionalFeature], notice: "Promotional feature deleted."
  end

  def confirm_destroy; end

  def reorder
    redirect_to admin_organisation_promotional_features_path(@organisation) and return unless @organisation.promotional_features.many?

    @promotional_features = @organisation.promotional_features
  end

  def update_order
    @organisation.reorder_promotional_features(params[:ordering])
    Whitehall::PublishingApi.republish_async(@organisation)
    flash[:notice] = "Promotional features reordered successfully"

    redirect_to admin_organisation_promotional_features_path(@organisation)
  end

private

  def get_layout
    design_system_actions = %w[confirm_destroy reorder update_order]
      if preview_design_system?(next_release: false) && design_system_actions.include?(action_name)
          "design_system"
      else
        "admin"
      end
  end

  def load_organisation
    @organisation = Organisation.allowed_promotional.find(params[:organisation_id])
  end

  def load_promotional_feature
    @promotional_feature = @organisation.promotional_features.find(params[:id])
  end

  def promotional_feature_params
    @promotional_feature_params ||= params.require(:promotional_feature).permit(
      :title,
      promotional_feature_items_attributes: [
        :summary,
        :image,
        :image_alt_text,
        :title,
        :title_url,
        :image_cache,
        :youtube_video_url,
        :youtube_video_alt_text,
        :image_or_youtube_video_url,
        { links_attributes: %i[url text _destroy] },
      ],
    )
  end

  def clean_image_or_youtube_video_url_param
    return if first_promotional_feature_item_params.blank?

    feature_item_type = first_promotional_feature_item_params.delete(:image_or_youtube_video_url)

    if feature_item_type == "youtube_video_url"
      first_promotional_feature_item_params["image"] = nil
      first_promotional_feature_item_params["image_alt_text"] = nil
    else
      first_promotional_feature_item_params["youtube_video_url"] = nil
      first_promotional_feature_item_params["youtube_video_alt_text"] = nil
    end
  end

  def first_promotional_feature_item_params
    @first_promotional_feature_item_params ||= promotional_feature_params.dig("promotional_feature_items_attributes", "0")
  end
end
