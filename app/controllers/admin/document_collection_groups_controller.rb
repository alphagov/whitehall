class Admin::DocumentCollectionGroupsController < Admin::BaseController
  before_filter :load_document_collection
  before_filter :load_document_collection_group, only: [:delete, :destroy, :edit, :update]

  def index
    @groups = @collection.groups
  end

  def new
    @group = @collection.groups.build
  end

  def create
    @group = @collection.groups.build(params[:document_collection_group])
    if @group.save
      redirect_to admin_document_collection_groups_path(@collection),
                  notice: "'#{@group.heading}' added"
    else
      render :new
    end
  end

  def update
    @group.update_attributes!(params[:document_collection_group])
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

  private
  def load_document_collection
    @collection = DocumentCollection.find(params[:document_collection_id])
  end

  def load_document_collection_group
    @group = @collection.groups.find(params[:id])
  end
end
