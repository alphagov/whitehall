class Admin::DocumentCollectionGroupsController < Admin::BaseController
  before_action :load_document_collection
  before_action :load_document_collection_group, only: %i[delete destroy edit update]

  def index
    @groups = @collection.groups
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
    @group.destroy
    redirect_to admin_document_collection_groups_path(@collection),
                notice: "'#{@group.heading}' was deleted"
  end

  def delete; end

  def update_memberships
    params[:groups].each_pair do |_key, group_params|
      group = @collection.groups.find(group_params[:id])
      group.ordering = group_params[:order]
      group.set_document_ids_in_order! group_params.fetch(:document_ids, []).map(&:to_i).uniq
    end
    respond_to do |format|
      format.html { render :index }
      format.json { render json: { result: :success } }
    end
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
end
