class Admin::DocumentSourcesController < Admin::BaseController
  before_filter :find_edition

  def new
    @document_source = @edition.document.build_document_source
  end

  def create
    @document_source = @edition.document.create_document_source(params[:document_source])
    if !@document_source.persisted?
      render :new
    else
      redirect_to admin_edition_path(@edition, anchor: 'document-sources')
    end
  end

  def edit
    @document_source = @edition.document.document_source
  end

  def update
    @document_source = @edition.document.document_source
    if @document_source.update_attributes(params[:document_source])
      redirect_to admin_edition_path(@edition, anchor: 'document-sources')
    else
      render :edit
    end
  end

  def destroy
    @edition.document.document_source.destroy
    redirect_to admin_edition_path(@edition, anchor: 'document-sources')
  end

  private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end
end
