class Admin::FactCheckRequestsController < Admin::BaseController
  before_filter :load_fact_check_request, only: [:show, :edit, :update]
  before_filter :check_document_availability, only: [:show, :edit]
  skip_before_filter :authenticate!, except: [:create]

  def show
  end

  def create
    @document = Document.unscoped.find(params[:document_id])
    attributes = params[:fact_check_request].merge(requestor: current_user)
    fact_check_request = @document.fact_check_requests.build(attributes)
    if @document.deleted?
      render "document_unavailable"
    elsif fact_check_request.save
      Notifications.fact_check(fact_check_request, mailer_url_options).deliver
      notice = "The policy has been sent to #{fact_check_request.email_address}"
      redirect_to admin_document_path(@document), notice: notice
    else
      alert = "There was a problem: #{fact_check_request.errors.full_messages.to_sentence}"
      redirect_to admin_document_path(@document), alert: alert
    end
  end

  def edit
  end

  def update
    if @fact_check_request.update_attributes(params[:fact_check_request])
      notice = "Your feedback has been saved"
      redirect_to admin_fact_check_request_path(@fact_check_request), notice: notice
    else
      render "document_unavailable"
    end
  end

  private

  def mailer_url_options
    options = { host: request.host }
    options[:protocol] = request.protocol unless request.protocol == 'http://'
    options[:port] = request.port unless request.port == 80 || request.port == 443
    options
  end

  def load_fact_check_request
    @fact_check_request = FactCheckRequest.from_param(params[:id])
    if @fact_check_request
      @document = Document.unscoped.find(@fact_check_request.document_id)
    else
      render text: "Not found", status: :not_found
    end
  end

  def check_document_availability
    if @document.deleted?
      render "document_unavailable"
    end
  end
end
