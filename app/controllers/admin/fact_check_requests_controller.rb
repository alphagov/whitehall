class Admin::FactCheckRequestsController < Admin::BaseController
  before_filter :load_fact_check_request, only: [:show, :edit, :update]
  before_filter :check_document_availability, only: [:show, :edit]
  skip_before_filter :authenticate!, except: [:create]

  def show
  end

  def create
    @document = Document.unscoped.find(params[:document_id])
    fact_check_request = @document.fact_check_requests.build(params[:fact_check_request])
    if @document.deleted?
      render "document_unavailable"
    elsif fact_check_request.save
      Notifications.fact_check(fact_check_request, current_user, mailer_url_options).deliver
      redirect_to admin_document_path(@document),
        notice: "The policy has been sent to #{params[:fact_check_request][:email_address]}"
    else
      redirect_to admin_document_path(@document),
        alert: "There was a problem: #{fact_check_request.errors.full_messages.to_sentence}"
    end
  end

  def edit
  end

  def update
    if @fact_check_request.update_attributes(params[:fact_check_request])
      redirect_to admin_fact_check_request_path(@fact_check_request),
                  notice: "Your feedback has been saved"
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
