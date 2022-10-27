class Admin::DocumentSourcesController < Admin::BaseController
  before_action :require_import_permission!
  before_action :find_edition
  before_action :forbid_editing_of_locked_documents
  layout :get_layout

  def edit
    render_design_system("edit", "edit_legacy", next_release: false)
  end

  def update
    @document_sources = params[:document_sources]
    @edition.document.document_sources.destroy_all
    @document_sources.split(/\r?\n/).each do |source|
      @edition.document.document_sources.create(url: source)
    end

    redirect_to admin_edition_path(@edition, anchor: "document-sources")
  end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def get_layout
    preview_design_system?(next_release: false) ? "design_system" : "admin"
  end
end
