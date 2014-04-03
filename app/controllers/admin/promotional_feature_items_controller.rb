class Admin::PromotionalFeatureItemsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :load_promotional_feature
  before_filter :load_promotional_feature_item, only: [:edit, :update, :destroy]

  def new
    @promotional_feature_item = @promotional_feature.promotional_feature_items.build
    @promotional_feature_item.links.build
  end

  def create
    @promotional_feature_item = @promotional_feature.promotional_feature_items.create(promotional_feature_item_params)
    if @promotional_feature_item.save
      redirect_to_feature 'Feature item added.'
    else
      render :new
    end
  end

  def edit
    @promotional_feature_item.links.build if @promotional_feature_item.links.empty?
  end

  def update
    if @promotional_feature_item.update_attributes(promotional_feature_item_params)
      redirect_to_feature 'Feature item updated.'
    else
      render :edit
    end
  end

  def destroy
    @promotional_feature_item.destroy
    redirect_to_feature 'Feature item deleted.'
  end

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
    redirect_to [:admin, @organisation, @promotional_feature], notice: notice
  end

  def promotional_feature_item_params
    params.require(:promotional_feature_item).permit(
      :summary, :image, :image_alt_text, :title, :title_url, :double_width,
      :image_cache,
      links_attributes: [:url, :text, :_destroy]
    )
  end
end
