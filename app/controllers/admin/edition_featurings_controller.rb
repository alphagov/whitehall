class Admin::EditionFeaturingsController < Admin::BaseController
  before_action :load_edition
  before_action :load_edition_featuring, only: %i[confirm_destroy destroy]

  def index
    filter_params = params.slice(:page, :type, :author, :organisation, :title)
                          .permit!
                          .to_h
                          .merge(
                            state: "published",
                            topical_event: @edition.to_param,
                            per_page: Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE,
                          )

    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @tagged_editions = editions_to_show

    @edition_featurings = @edition.topical_event_featurings
    @featurable_offsite_links = @edition.offsite_links
    @featurable_editions = @edition.topical_event_documents
                            .page(params[:page])
                            .per(Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE)
  end

  def new
    featured_edition = Edition.find(params[:edition_id]) if params[:edition_id].present?
    featured_offsite_link = OffsiteLink.find(params[:offsite_link_id]) if params[:offsite_link_id].present?
    @edition_featuring = @edition.topical_event_featurings.build(edition: featured_edition, offsite_link: featured_offsite_link)
    @edition_featuring.build_image
  end

  def create
    @edition_featuring = @edition.feature(topical_event_featuring_params)
    if @edition_featuring.valid?
      flash[:notice] = if featuring_a_document?
                         "#{@edition_featuring.edition.title} has been featured on #{@edition.name}"
                       else
                         "#{@edition_featuring.offsite_link.title} has been featured on #{@edition.name}"
                       end
      redirect_to polymorphic_path([:admin, @edition, :topical_event_featurings])
    else
      render :new
    end
  end

  def reorder; end

  def order
    @edition.topical_event_featurings.reorder_without_callbacks!(order_params)
    Whitehall::PublishingApi.republish_async(@edition)

    redirect_to polymorphic_path([:admin, @edition, :topical_event_featurings]), notice: "Featured items re-ordered"
  end

  def confirm_destroy; end

  def destroy
    if featuring_a_document?
      edition = @edition_featuring.edition
      @edition_featuring.destroy!
      flash[:notice] = "#{edition.title} has been unfeatured from #{@edition.name}"
    else
      offsite_link = @edition_featuring.offsite_link
      @edition_featuring.destroy!
      flash[:notice] = "#{offsite_link.title} has been unfeatured from #{@edition.name}"
    end
    redirect_to polymorphic_path([:admin, @edition, :topical_event_featurings])
  end

  helper_method :featuring_a_document?
  def featuring_a_document?
    @edition_featuring.edition.present?
  end

private

  def load_edition
    @edition = if params[:topical_event_id].present?
                 TopicalEvent.find(params[:topical_event_id])
               elsif params[:standard_edition_id].present?
                 StandardEdition.find(params[:standard_edition_id])
               end
  end

  def load_edition_featuring
    @edition_featuring = @edition.topical_event_featurings.find(params[:id])
  end

  def editions_to_show
    @filter.editions
    # if filter_values_set?
    #   @filter.editions
    # else
    #   # editions = if @edition.respond_to?(:topical_event_documents)
    #   #               @edition.topical_event_documents
    #   #                             .page(params[:page])
    #   #                             .per(Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE)
    #   #             else
    #   #               @edition.editions.published
    #   #                                      .with_translations
    #   #                                      .order("editions.created_at DESC")
    #   #                                      .page(params[:page])
    #   #                                      .per(Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE)
    #   #             end
    #   @topical_event.editions.published
    #                           .with_translations
    #                           .order("editions.created_at DESC")
    #                           .page(params[:page])
    #                           .per(Admin::EditionFilter::GOVUK_DESIGN_SYSTEM_PER_PAGE)
    # end

    #   editions
    # end
  end

  def filter_values_set?
    params.slice(:page, :type, :author, :organisation, :title).permit!.to_h.any?
  end

  def topical_event_featuring_params
    params.require(:topical_event_featuring).permit(
      :alt_text,
      :edition_id,
      :offsite_link_id,
      image_attributes: %i[file],
    )
  end

  def order_params
    params.require(:topical_event_featurings)["ordering"]
  end
end
