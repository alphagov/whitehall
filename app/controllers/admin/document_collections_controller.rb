class Admin::DocumentCollectionsController < Admin::BaseController
  before_filter :find_organisation
  before_filter :find_document_collection, except: [:new, :create]

  def new
    @document_collection = @organisation.document_collections.build
  end

  def create
    @document_collection = @organisation.document_collections.build(params[:document_collection])
    if @document_collection.save
      redirect_to admin_organisation_document_collection_path(@organisation, @document_collection)
    else
      render action: :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @document_collection.update_attributes(params[:document_collection])
      redirect_to admin_organisation_document_collection_path(@organisation, @document_collection)
    else
      render action: :edit
    end
  end

  private

  def find_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def find_document_collection
    @document_collection = @organisation.document_collections.find(params[:id])
  end
end
