class ConsultationsController < DocumentsController
  def index
    filter_params = params.permit!.except(:controller, :action, :format, :_, :host)
    redirect_to publications_path(filter_params.merge(publication_filter_option: 'consultations').to_h)
  end
end
