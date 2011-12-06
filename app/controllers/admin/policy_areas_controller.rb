class Admin::PolicyAreasController < Admin::BaseController

  before_filter :default_arrays_of_ids_to_empty, only: [:update]

  def index
    @policy_areas = PolicyAreasPresenter.new
  end

  def new
    @policy_area = PolicyArea.new
  end

  def create
    @policy_area = PolicyArea.new(params[:policy_area])
    if @policy_area.save
      redirect_to admin_policy_areas_path, notice: "Policy area created"
    else
      render action: "new"
    end
  end

  def edit
    @policy_area = PolicyArea.find(params[:id])
  end

  def update
    @policy_area = PolicyArea.find(params[:id])
    if @policy_area.update_attributes(params[:policy_area])
      redirect_to admin_policy_areas_path, notice: "Policy area updated"
    else
      render action: "edit"
    end
  end

  def feature
    @policy_area = PolicyArea.find(params[:id])
    @policy_area.update_attributes(featured: true)
    redirect_to admin_policy_areas_path, notice: "The policy area #{@policy_area.name} is now featured"
  end

  def unfeature
    @policy_area = PolicyArea.find(params[:id])
    @policy_area.update_attributes(featured: false)
    redirect_to admin_policy_areas_path, notice: "The policy area #{@policy_area.name} is no longer featured"
  end

  def destroy
    @policy_area = PolicyArea.find(params[:id])
    @policy_area.delete!
    if @policy_area.deleted?
      redirect_to admin_policy_areas_path, notice: "Policy area destroyed"
    else
      redirect_to admin_policy_areas_path, alert: "Cannot destroy policy area with associated content"
    end
  end

  class PolicyAreasPresenter < Whitehall::Presenters::Collection
    def initialize
      super(PolicyArea.all)
    end

    present_object_with do
      def document_breakdown
        {
          "featured policy" => @record.policy_area_memberships.where(featured: true).count,
          "published policy" => @record.policies.published.count
        }
      end
    end
  end

  private

  def default_arrays_of_ids_to_empty
    params[:policy_area][:related_policy_area_ids] ||= []
  end
end