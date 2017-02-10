class ConsultationsController < DocumentsController
  def index
    filter_params = params.except(:controller, :action, :format, :_)
    redirect_to publications_path(filter_params.merge(publication_filter_option: 'consultations'))
  end
end
