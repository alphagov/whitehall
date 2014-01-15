class Admin::PromotionalFeaturesController < Admin::BaseController
  before_filter :load_executive_office
  before_filter :load_promotional_feature, only: [:show, :edit, :update, :destroy]

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
      redirect_to [:admin, @organisation, @promotional_feature], notice: 'Promotional feature created'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @promotional_feature.update_attributes(promotional_feature_params)
      redirect_to [:admin, @organisation, @promotional_feature], notice: 'Promotional feature updated'
    else
      render :edit
    end
  end

  def destroy
    @promotional_feature.destroy
    redirect_to [:admin, @organisation, PromotionalFeature], notice: 'Promotional feature deleted.'
  end

  private

  def load_executive_office
    @organisation = Organisation.executive_offices.find(params[:organisation_id])
  end

  def load_promotional_feature
    @promotional_feature = @organisation.promotional_features.find(params[:id])
  end

  def promotional_feature_params
    params.require(:promotional_feature).permit(
      :title,
      promotional_feature_items_attributes: [
        :summary, :image, :image_alt_text, :title, :title_url, :double_width,
        :image_cache,
        links_attributes: [:url, :text, :_destroy]
      ]
    )
  end
end
