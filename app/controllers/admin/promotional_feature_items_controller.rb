class Admin::PromotionalFeatureItemsController < Admin::BaseController
  before_filter :load_executive_office
  before_filter :load_promotional_feature
  before_filter :load_promotional_feature_item, only: [:edit, :update, :destroy]

  def new
    @promotional_feature_item = @promotional_feature.promotional_feature_items.build
  end

  def create
    @promotional_feature_item = @promotional_feature.promotional_feature_items.create(params[:promotional_feature_item])
    if @promotional_feature_item.save
      redirect_to_feature 'Feature item added.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @promotional_feature_item.update_attributes(params[:promotional_feature_item])
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

  def load_executive_office
    @organisation = Organisation.executive_offices.find(params[:organisation_id])
  end

  def load_promotional_feature
    @promotional_feature = @organisation.promotional_features.find(params[:promotional_feature_id])
  end

  def load_promotional_feature_item
    @promotional_feature_item = @promotional_feature.promotional_feature_items.find(params[:id])
  end

  def redirect_to_feature(notice=nil)
    redirect_to [:admin, @organisation, @promotional_feature], notice: notice
  end
end
