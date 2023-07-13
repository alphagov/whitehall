class Admin::TopicalEventFeaturingsController < Admin::BaseController
  before_action :load_topical_event
  before_action :load_topical_event_featuring, only: %i[confirm_destroy destroy]
  layout "design_system"

  def index
    filter_params = params.slice(:page, :type, :author, :organisation, :title)
                          .permit!
                          .to_h
                          .merge(
                            state: "published",
                            topical_event: @topical_event.to_param,
                            per_page: Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE,
                          )

    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @tagged_editions = editions_to_show

    @topical_event_featurings = @topical_event.topical_event_featurings
    @featurable_offsite_links = @topical_event.offsite_links
  end

  def new
    featured_edition = Edition.find(params[:edition_id]) if params[:edition_id].present?
    featured_offsite_link = OffsiteLink.find(params[:offsite_link_id]) if params[:offsite_link_id].present?
    @topical_event_featuring = @topical_event.topical_event_featurings.build(edition: featured_edition, offsite_link: featured_offsite_link)
    @topical_event_featuring.build_image
  end

  def create
    @topical_event_featuring = @topical_event.feature(topical_event_featuring_params)
    if @topical_event_featuring.valid?
      flash[:notice] = if featuring_a_document?
                         "#{@topical_event_featuring.edition.title} has been featured on #{@topical_event.name}"
                       else
                         "#{@topical_event_featuring.offsite_link.title} has been featured on #{@topical_event.name}"
                       end
      redirect_to polymorphic_path([:admin, @topical_event, :topical_event_featurings])
    else
      render :new
    end
  end

  def reorder; end

  def order
    params[:ordering].each do |topical_event_featuring_id, ordering|
      @topical_event.topical_event_featurings.find(topical_event_featuring_id).update_column(:ordering, ordering)
    end

    Whitehall::PublishingApi.republish_async(@topical_event)

    redirect_to polymorphic_path([:admin, @topical_event, :topical_event_featurings]), notice: "Featured items re-ordered"
  end

  def confirm_destroy; end

  def destroy
    if featuring_a_document?
      edition = @topical_event_featuring.edition
      @topical_event_featuring.destroy!
      flash[:notice] = "#{edition.title} has been unfeatured from #{@topical_event.name}"
    else
      offsite_link = @topical_event_featuring.offsite_link
      @topical_event_featuring.destroy!
      flash[:notice] = "#{offsite_link.title} has been unfeatured from #{@topical_event.name}"
    end
    redirect_to polymorphic_path([:admin, @topical_event, :topical_event_featurings])
  end

  helper_method :featuring_a_document?
  def featuring_a_document?
    @topical_event_featuring.edition.present?
  end

private

  def load_topical_event
    @topical_event = TopicalEvent.find(params[:topical_event_id])
  end

  def load_topical_event_featuring
    @topical_event_featuring = @topical_event.topical_event_featurings.find(params[:id])
  end

  def editions_to_show
    if filter_values_set?
      @filter.editions
    else
      @topical_event.editions.published
                              .with_translations
                              .order("editions.created_at DESC")
                              .page(params[:page])
                              .per(Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE)
    end
  end

  def filter_values_set?
    params.slice(:page, :type, :author, :organisation, :title).permit!.to_h.any?
  end

  def topical_event_featuring_params
    params.require(:topical_event_featuring).permit(
      :alt_text,
      :edition_id,
      :offsite_link_id,
      image_attributes: %i[file file_cache],
    )
  end
end
