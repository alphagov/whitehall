class Admin::TopicalEventFeaturingsController < Admin::BaseController
  before_action :load_topical_event
  layout :get_layout

  def index
    filter_params = params.slice(:page, :type, :author, :organisation, :title)
                          .permit!
                          .to_h
                          .merge(state: "published", topical_event: @topical_event.to_param)

    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @tagged_editions = editions_to_show

    @topical_event_featurings = @topical_event.topical_event_featurings
    @featurable_offsite_links = @topical_event.offsite_links

    if request.xhr?
      render partial: "admin/topical_event_featurings/legacy_featured_documents"
    else
      render_design_system(:index, :legacy_index)
    end
  end

  def new
    featured_edition = Edition.find(params[:edition_id]) if params[:edition_id].present?
    featured_offsite_link = OffsiteLink.find(params[:offsite_link_id]) if params[:offsite_link_id].present?
    @topical_event_featuring = @topical_event.topical_event_featurings.build(edition: featured_edition, offsite_link: featured_offsite_link)
    @topical_event_featuring.build_image

    render_design_system(:new, :legacy_new)
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
      render_design_system(:new, :legacy_new)
    end
  end

  def order
    params[:ordering].each do |topical_event_featuring_id, ordering|
      @topical_event.topical_event_featurings.find(topical_event_featuring_id).update_column(:ordering, ordering)
    end

    Whitehall::PublishingApi.republish_async(@topical_event)

    redirect_to polymorphic_path([:admin, @topical_event, :topical_event_featurings]), notice: "Featured items re-ordered"
  end

  def destroy
    @topical_event_featuring = @topical_event.topical_event_featurings.find(params[:id])

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

  def get_layout
    design_system_actions = []
    design_system_actions += %w[new create index] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def load_topical_event
    @topical_event = TopicalEvent.find(params[:topical_event_id] || params[:topic_id])
  end

  def editions_to_show
    if filter_values_set?
      @filter.editions
    else
      @topical_event.editions.published
                              .with_translations
                              .order("editions.created_at DESC")
                              .page(params[:page])
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
