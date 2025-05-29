class Admin::NewDocumentController < Admin::BaseController
  def index
    @document_types = Document::View::New.types_for(current_user)
  end

  def new_document_options_redirect
    if params[:new_document_options].present?
      new_document_type = params.require(:new_document_options)
      redirect_to send(Document::View::New.redirect_path_helper(new_document_type))
    else
      redirect_to admin_new_document_path, alert: "Please select a new document option"
    end
  end
end
