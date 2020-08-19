class Admin::DocumentCollectionGroupsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group, only: %i[delete destroy edit update]

  def edit; end

  def index
    @groups = @collection.groups.includes(
      memberships: [
        { document: { latest_edition: %i[translations] } },
        :non_whitehall_link,
      ],
    )
  end

  def new
    @group = @collection.groups.build
  end

  def create
    @group = @collection.groups.build(document_collection_group_params)
    if @group.save
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: "'#{@group.heading}' added"
    else
      render :new
    end
  end

  def update
    @group.update!(document_collection_group_params)
    redirect_to admin_document_collection_groups_path(@collection),
                notice: "'#{@group.heading}' saved"
  rescue ActiveRecord::RecordInvalid
    render :edit
  end

  def destroy
    @group.destroy!
    redirect_to admin_document_collection_groups_path(@collection),
                notice: "'#{@group.heading}' was deleted"
  end

  def delete; end

  def update_memberships
    add_moved_groups
    reorder_groups
    respond_to do |format|
      format.html { render :index }
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
