class Admin::ClassificationsController < Admin::BaseController
  helper_method :model_class, :model_name, :human_friendly_model_name

  before_action :build_object, only: [:new]
  before_action :load_object, only: %i[show edit]
  before_action :remove_blank_parameters, only: %i[create update]

  def index
    @classifications = model_class.includes(:related_classifications).order(:name)
  end

  def new; end

  def create
    @classification = model_class.new(object_params)
    if @classification.save
      redirect_to [:admin, @classification], notice: "#{human_friendly_model_name} created"
    else
      render action: "new"
    end
  end

  def edit; end

  def update
    @classification = model_class.friendly.find(params[:id])
    if @classification.update(object_params)
      redirect_to [:admin, @classification], notice: "#{human_friendly_model_name} updated"
    else
      render action: "edit"
    end
  end

  def destroy
    @classification = model_class.friendly.find(params[:id])
    @classification.delete!
    if @classification.deleted?
      redirect_to [:admin, model_class], notice: "#{human_friendly_model_name} destroyed"
    else
      redirect_to [:admin, model_class], alert: "Cannot destroy #{human_friendly_model_name} with associated content"
    end
  end

  def human_friendly_model_name
    # `PolicyArea` used to be called `Topic` in the frontend part of Whitehall.
    # This hack can be removed when `Topic` will become `PolicyArea` in the
    # backend too.
    return "Policy area" if model_name == "topic"

    model_name.humanize
  end

  def build_object
    @classification = model_class.new
  end

  def load_object
    @classification = model_class.friendly.find(params[:id])
  end

  def model_name
    model_class.name.underscore
  end

private

  def object_params
    params.require(model_name).permit(
      :name, :description, :logo, :logo_alt_text, :logo_cache, :remove_logo,
      :start_date, :end_date,
      policy_content_ids: [],
      related_classification_ids: [],
      classification_memberships_attributes: %i[id ordering],
      social_media_accounts_attributes: %i[social_media_service_id url _destroy id],
      featured_links_attributes: %i[title url _destroy id],
      organisation_classifications_attributes: %i[id lead lead_ordering]
    )
  end

  def remove_blank_parameters
    return if params[model_name][:policy_content_ids].blank?

    params[model_name][:policy_content_ids].reject!(&:blank?)
  end
end
