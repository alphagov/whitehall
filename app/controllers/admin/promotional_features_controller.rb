class Admin::PromotionalFeaturesController < Admin::BaseController
  before_action :load_organisation
  before_action :load_promotional_feature, only: %i[show edit update destroy]
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
      render :edit
    end
  end

  def destroy
    @promotional_feature.destroy!
    Whitehall::PublishingApi.republish_async(@organisation)
    redirect_to [:admin, @organisation, PromotionalFeature], notice: "Promotional feature deleted."
  end

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
    case action_name
    when "reorder", "update_order"
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
    params.require(:promotional_feature).permit(
      :title,
      promotional_feature_items_attributes: [
        :summary,
        :image,
        :image_alt_text,
        :title,
        :title_url,
        :double_width,
        :image_cache,
        { links_attributes: %i[url text _destroy] },
      ],
    )
  end
end
