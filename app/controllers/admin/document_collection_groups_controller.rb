class Admin::DocumentCollectionGroupsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group, only: %i[confirm_destroy destroy edit update show]

  def index
    @groups = @collection.groups.includes(
      memberships: [
        { document: { latest_edition: %i[translations] } },
        :non_whitehall_link,
      ],
    )
  end

  def show; end

  def new
    @group = @collection.groups.build
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

  def edit; end

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
    @collection.groups.reorder!(order_params)

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
    redirect_to admin_document_collection_groups_path(@collection) unless @collection.groups.many?
  end

private

  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:id])
  end

  def document_collection_group_params
    params.require(:document_collection_group).permit(:body, :heading)
  end

  def order_params
    params.require(:document_collection_groups)["ordering"]
  end
end
