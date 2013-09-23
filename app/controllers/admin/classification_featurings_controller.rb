class Admin::ClassificationFeaturingsController < Admin::BaseController
  before_filter :load_classification
  before_filter :load_featuring, only: [:edit, :destroy]
  before_filter :build_featuring, only: [:new]

  def create
    @classification_featuring = @classification.feature(params[:classification_featuring])
    if @classification_featuring.valid?
      flash[:notice] = "#{@classification_featuring.edition.title} has been featured on #{@classification.name}"
      redirect_to polymorphic_path([:admin, @classification, :classification_featurings])
    else
      render :new
    end
  end

  def destroy
    edition = @classification_featuring.edition
    @classification_featuring.destroy
    flash[:notice] = "#{edition.title} has been unfeatured from #{@classification.name}"
    redirect_to polymorphic_path([:admin, @classification, :classification_featurings])
  end

  def load_classification
    @classification = Classification.find_by_slug(params[:topical_event_id] || params[:topic_id])
  end

  def build_featuring
    @classification_featuring = @classification.classification_featurings.build(edition_id: params[:edition_id])
    @classification_featuring.build_image
  end

  def load_featuring
    @classification_featuring = @classification.classification_featurings.find(params[:id])
  end
end