class Admin::DocumentCollectionGroupsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group, only: %i[confirm_destroy destroy edit update show]
  layout :get_layout

  def index
    @groups = @collection.groups.includes(
      memberships: [
        { document: { latest_edition: %i[translations] } },
        :non_whitehall_link,
      ],
    )

    render_design_system(:index, :legacy_index)
  end

  def show
    forbidden! unless new_design_system?
  end

  def new
    @group = @collection.groups.build
    render_design_system(:new, :legacy_new)
  end

  def create
    @group = @collection.groups.build(document_collection_group_params)
    if @group.save
      flash_message = get_layout == "design_system" ? "New group has been created" : "'#{@group.heading}' added"
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: flash_message
    else
      render_design_system(:new, :legacy_new)
    end
  end

  def edit
    render_design_system(:edit, :legacy_edit)
  end

  def update
    @group.update!(document_collection_group_params)
    flash_message = get_layout == "design_system" ? "Group details have been updated" : "'#{@group.heading}' saved"
    redirect_to admin_document_collection_groups_path(@collection),
                notice: flash_message
  rescue ActiveRecord::RecordInvalid
    render_design_system(:edit, :legacy_edit)
  end

  def destroy
    @group.destroy!
    flash_message = get_layout == "design_system" ? "Group has been deleted" : "'#{@group.heading}' was deleted"
    redirect_to admin_document_collection_groups_path(@collection),
                notice: flash_message
  end

  def confirm_destroy
    redirect_to admin_document_collection_groups_path(@collection) and return if get_layout == "design_system" && !@collection.groups.many?

    render_design_system(:confirm_destroy, :legacy_confirm_destroy)
  end

  def update_memberships
    add_moved_groups
    reorder_groups
    respond_to do |format|
      format.html { render :legacy_index }
      format.json { render json: { result: :success } }
    end
  end

private

  def get_layout
    design_system_actions = %w[index confirm_destroy destroy new create edit update show] if preview_design_system?(next_release: false)

    if design_system_actions&.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def add_moved_groups
    params[:groups].each do |_key, group_params|
      group = @collection.groups.find(group_params[:id])
      new_ids = membership_ids(group_params) - group.membership_ids
      group.membership_ids += new_ids
    end
  end

  def reorder_groups
    params[:groups].each do |_key, group_params|
      group = @collection.groups.find(group_params[:id])
      group.ordering = group_params[:order]
      group.set_membership_ids_in_order! membership_ids(group_params)
    end
  end

  def membership_ids(group_params)
    group_params.fetch(:membership_ids, []).map(&:to_i)
  end

  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:id])
  end

  def document_collection_group_params
    params.require(:document_collection_group).permit(:body, :heading)
  end
end
