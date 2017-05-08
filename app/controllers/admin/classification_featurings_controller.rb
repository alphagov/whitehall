class Admin::ClassificationFeaturingsController < Admin::BaseController
  before_action :load_classification
  before_action :load_featuring, only: [:edit, :destroy]

  def index
    filter_params = params.slice(:page, :type, :author, :organisation, :title).
      merge(state: 'published', classification: @classification.to_param)
    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)

    @tagged_editions = editions_to_show

    @classification_featurings = @classification.classification_featurings
    @featurable_offsite_links = @classification.offsite_links

    if request.xhr?
      render partial: 'admin/classification_featurings/featured_documents'
    else
      render :index
    end
  end

  def new
    featured_edition = Edition.find(params[:edition_id]) if params[:edition_id].present?
    featured_offsite_link = OffsiteLink.find(params[:offsite_link_id]) if params[:offsite_link_id].present?
    @classification_featuring = @classification.classification_featurings.build(edition: featured_edition, offsite_link: featured_offsite_link)
    @classification_featuring.build_image
  end

  def create
    @classification_featuring = @classification.feature(params[:classification_featuring])
    if @classification_featuring.valid?
      if featuring_a_document?
        flash[:notice] = "#{@classification_featuring.edition.title} has been featured on #{@classification.name}"
      else
        flash[:notice] = "#{@classification_featuring.offsite_link.title} has been featured on #{@classification.name}"
      end
      redirect_to polymorphic_path([:admin, @classification, :classification_featurings])
    else
      render :new
    end
  end

  def order
    params[:ordering].each do |classification_featuring_id, ordering|
      @classification.classification_featurings.find(classification_featuring_id).update_column(:ordering, ordering)
    end
    redirect_to polymorphic_path([:admin, @classification, :classification_featurings]), notice: 'Featured items re-ordered'
  end

  def destroy
    if featuring_a_document?
      edition = @classification_featuring.edition
      @classification_featuring.destroy
      flash[:notice] = "#{edition.title} has been unfeatured from #{@classification.name}"
    else
      offsite_link = @classification_featuring.offsite_link
      @classification_featuring.destroy
      flash[:notice] = "#{offsite_link.title} has been unfeatured from #{@classification.name}"
    end
    redirect_to polymorphic_path([:admin, @classification, :classification_featurings])
  end

  helper_method :featuring_a_document?
  def featuring_a_document?
    @classification_featuring.edition.present?
  end

  private

  def load_classification
    @classification = Classification.find(params[:topical_event_id] || params[:topic_id])
  end

  def load_featuring
    @classification_featuring = @classification.classification_featurings.find(params[:id])
  end

  def editions_to_show
    if filter_values_set?
      @filter.editions
    else
      @classification.editions.published
                              .with_translations
                              .order('editions.created_at DESC')
                              .page(params[:page])
    end
  end

  def filter_values_set?
    params.slice(:type, :author, :organisation, :title).length > 0
  end
end
