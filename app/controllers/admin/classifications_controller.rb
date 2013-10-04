class Admin::ClassificationsController < Admin::BaseController
  helper_method :model_class, :model_name, :human_friendly_model_name

  before_filter :build_object, only: [:new]
  before_filter :load_object, only: [:show, :edit]

  def index
    @classifications = model_class.order(:name)
  end

  def new
  end

  def create
    @classification = model_class.new(object_params)
    if @classification.save
      redirect_to [:admin, @classification], notice: "#{human_friendly_model_name} created"
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    @classification = model_class.find(params[:id])
    if @classification.update_attributes(object_params)
      redirect_to [:admin, @classification], notice: "#{human_friendly_model_name} updated"
    else
      render action: "edit"
    end
  end

  def destroy
    @classification = model_class.find(params[:id])
    @classification.delete!
    if @classification.deleted?
      redirect_to [:admin, model_class], notice: "#{human_friendly_model_name} destroyed"
    else
      redirect_to [:admin, model_class], alert: "Cannot destroy #{human_friendly_model_name} with associated content"
    end
  end

  def human_friendly_model_name
    model_name.humanize
  end

  def build_object
    @classification = model_class.new
  end

  def load_object
    @classification = model_class.find(params[:id])
  end

  def model_name
    model_class.name.underscore
  end

  private

  def object_params
    params[model_name]
  end
end
