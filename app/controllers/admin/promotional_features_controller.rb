class Admin::PromotionalFeaturesController < Admin::BaseController
  before_filter :load_executive_office
  before_filter :load_promotional_feature, only: [:show, :edit, :update, :destroy]

  def index
    @promotional_features = @organisation.promotional_features
  end

  def new
    @promotional_feature = @organisation.promotional_features.build
  end

  def create
    @promotional_feature = @organisation.promotional_features.build(params[:promotional_feature])
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
    if @promotional_feature.update_attributes(params[:promotional_feature])
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
end
