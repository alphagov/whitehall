class Admin::DocumentSourcesController < Admin::BaseController
  before_filter :find_edition

  def new
    @document_source = @edition.document.document_sources.build
  end

  def create
    @document_source = @edition.document.document_sources.build(params[:document_source])
    if @document_source.save
      redirect_to admin_edition_path(@edition, anchor: 'document-sources')
    else
      render :new
    end
  end

  def edit
    @document_source = @edition.document.document_sources.first
  end

  def update
    @document_source = @edition.document.document_sources.first
    if @document_source.update_attributes(params[:document_source])
      redirect_to admin_edition_path(@edition, anchor: 'document-sources')
    else
      render :edit
    end
  end

  def destroy
    @edition.document.document_sources.first.destroy
    redirect_to admin_edition_path(@edition, anchor: 'document-sources')
  end

  private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end
end
