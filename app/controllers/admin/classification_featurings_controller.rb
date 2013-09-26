class Admin::ClassificationFeaturingsController < Admin::BaseController
  before_filter :load_classification
  before_filter :load_featuring, only: [:edit, :destroy]

  def index
    @tagged_editions = @classification.editions.published.with_translations
    @classification_featurings = @classification.classification_featurings
  end

  def new
    @classification_featuring = @classification.classification_featurings.build(edition_id: params[:edition_id])
    @classification_featuring.build_image
  end

  def create
    @classification_featuring = @classification.feature(params[:classification_featuring])
    if @classification_featuring.valid?
      flash[:notice] = "#{@classification_featuring.edition.title} has been featured on #{@classification.name}"
      redirect_to polymorphic_path([:admin, @classification, :classification_featurings])
    else
      render :new
    end
  end

  def order
    params[:ordering].each do |classification_featuring_id, ordering|
      @classification.classification_featurings.find(classification_featuring_id).update_column(:ordering, ordering)
    end
    redirect_to polymorphic_path([:admin, @classification, :classification_featurings]), notice: 'Featured documents re-ordered'
  end

  def destroy
    edition = @classification_featuring.edition
    @classification_featuring.destroy
    flash[:notice] = "#{edition.title} has been unfeatured from #{@classification.name}"
    redirect_to polymorphic_path([:admin, @classification, :classification_featurings])
  end

  private

  def load_classification
    @classification = Classification.find(params[:topical_event_id] || params[:topic_id])
  end

  def load_featuring
    @classification_featuring = @classification.classification_featurings.find(params[:id])
  end
end
