class Admin::DocumentCollectionGroupsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group, only: %i[confirm_destroy destroy edit update show]

  layout "design_system"

  def index
    @groups = @collection.groups.includes(
      memberships: [
        { document: { latest_edition: %i[translations] } },
        :non_whitehall_link,
      ],
    )

    render :index
  end

  def show; end

  def new
    @group = @collection.groups.build
    render :new
  end

  def create
    @group = @collection.groups.build(document_collection_group_params)
    if @group.save
      flash_message = "New group has been created"
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: flash_message
    else
      render :new
    end
  end

  def edit
    render :edit
  end

  def update
    @group.update!(document_collection_group_params)
    flash_message = "Group details have been updated"
    redirect_to admin_document_collection_groups_path(@collection),
                notice: flash_message
  rescue ActiveRecord::RecordInvalid
    render :edit
  end

  def reorder; end

  def order
    params[:ordering].each do |group_id, ordering|
      @collection.groups.find(group_id).update_column(:ordering, ordering)
    end

    flash_message = "Group has been reordered"
    redirect_to admin_document_collection_groups_path(@collection), notice: flash_message
  end

  def destroy
    @group.destroy!
    flash_message = "Group has been deleted"
    redirect_to admin_document_collection_groups_path(@collection),
                notice: flash_message
  end

  def confirm_destroy
    redirect_to admin_document_collection_groups_path(@collection) and return unless @collection.groups.many?

    render :confirm_destroy
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
