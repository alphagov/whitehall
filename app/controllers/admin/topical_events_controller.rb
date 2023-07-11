class Admin::TopicalEventsController < Admin::BaseController
  before_action :load_object, only: %i[show edit confirm_destroy destroy]
  before_action :build_object, only: [:new]
  before_action :build_associated_objects, only: %i[new edit]
  before_action :destroy_blank_social_media_accounts, only: %i[create update]

  layout "design_system"

  def show; end

  def index
    @topical_events = TopicalEvent.order(:name)
  end

  def new; end

  def create
    @topical_event = TopicalEvent.new(object_params)
    if @topical_event.save
      redirect_to [:admin, @topical_event], notice: "Topical event created"
    else
      build_associated_objects
      render :new
    end
  end

  def edit; end

  def update
    @topical_event = TopicalEvent.friendly.find(params[:id])
    if @topical_event.update(object_params)
      if object_params[:topical_event_featurings_attributes]
        redirect_to [:admin, @topical_event, :topical_event_featurings], notice: "Order of featured items updated"
      else
        redirect_to [:admin, TopicalEvent.new], notice: "Topical event updated"
      end
    else
      build_associated_objects
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    @topical_event.delete!
    if @topical_event.deleted?
      redirect_to [:admin, TopicalEvent], notice: "Topical event destroyed"
    else
      redirect_to [:admin, TopicalEvent], alert: "Cannot destroy Topical event with associated content"
    end
  end

  def build_object
    @topical_event = TopicalEvent.new
  end

  def load_object
    @topical_event = TopicalEvent.friendly.find(params[:id])
  end

  def build_associated_objects
    @topical_event.social_media_accounts.build if @topical_event.social_media_accounts.blank?
  end

  def destroy_blank_social_media_accounts
    if params[:topical_event][:social_media_accounts_attributes]
      params[:topical_event][:social_media_accounts_attributes].each_pair do |_key, account|
        if account[:social_media_service_id].blank? && account[:url].blank?
          account[:_destroy] = "1"
        end
      end
    end
  end

  def object_params
    params.require(:topical_event).permit(
      :name,
      :summary,
      :description,
      :logo,
      :logo_alt_text,
      :logo_cache,
      :remove_logo,
      :start_date,
      :end_date,
      related_topical_event_ids: [],
      topical_event_membership_attributes: %i[id ordering],
      social_media_accounts_attributes: %i[social_media_service_id url _destroy id],
      featured_links_attributes: %i[title url _destroy id],
      topical_event_organisations_attributes: %i[id lead lead_ordering],
    )
  end
end
