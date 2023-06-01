class Admin::TopicalEventsController < Admin::BaseController
  helper_method :model_class, :model_name, :human_friendly_model_name

  before_action :load_object, only: %i[show edit]
  before_action :build_object, only: [:new]
  before_action :build_associated_objects, only: %i[new edit]
  before_action :destroy_blank_social_media_accounts, only: %i[create update]

  layout :get_layout

  def show
    render_design_system(:show, :show_legacy, next_release: false)
  end

  def index
    @topical_events = model_class.order(:name)
  end

  def new; end

  def create
    @topical_event = model_class.new(object_params)
    if @topical_event.save
      redirect_to [:admin, @topical_event], notice: "#{human_friendly_model_name} created"
    else
      render action: "new"
    end
  end

  def edit; end

  def update
    @topical_event = TopicalEvent.friendly.find(params[:id])
    if @topical_event.update(object_params)
      if object_params[:topical_event_featurings_attributes]
        redirect_to [:admin, @topical_event, :topical_event_featurings], notice: "Order of featured items updated"
      else
        redirect_to [:admin, TopicalEvent.new], notice: "#{human_friendly_model_name} updated"
      end
    else
      render action: "edit"
    end
  end

  def destroy
    @topical_event = model_class.friendly.find(params[:id])
    @topical_event.delete!
    if @topical_event.deleted?
      redirect_to [:admin, model_class], notice: "#{human_friendly_model_name} destroyed"
    else
      redirect_to [:admin, model_class], alert: "Cannot destroy #{human_friendly_model_name} with associated content"
    end
  end

  def human_friendly_model_name
    model_name.humanize
  end

  def build_object
    @topical_event = model_class.new
  end

  def load_object
    @topical_event = model_class.friendly.find(params[:id])
  end

  def model_name
    model_class.name.underscore
  end

private

  def get_layout
    design_system_actions = []
    design_system_actions += %w[show] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def model_class
    TopicalEvent
  end

  def build_associated_objects
    @topical_event.social_media_accounts.build
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
    params.require(model_name).permit(
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
