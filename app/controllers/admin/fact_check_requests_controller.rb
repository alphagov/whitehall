class Admin::FactCheckRequestsController < Admin::BaseController
  before_filter :load_fact_check_request, only: [:show, :edit, :update]
  before_filter :load_edition, only: [:create]
  before_filter :enforce_permissions!, only: [:create]
  before_filter :check_edition_availability, only: [:show, :edit]
  skip_before_filter :authenticate_user!, except: [:create]
  skip_before_filter :require_signin_permission!, except: [:create]

  def load_edition
    @edition = Edition.unscoped.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:make_fact_check, @edition)
  end

  def show
  end

  def create
    unless @edition.accessible_by?(current_user)
      render "admin/editions/forbidden", status: 403
      return
    end
    attributes = params[:fact_check_request].merge(requestor: current_user)
    fact_check_request = @edition.fact_check_requests.build(attributes)
    if @edition.deleted?
      render "edition_unavailable"
    elsif fact_check_request.save
      Notifications.fact_check_request(fact_check_request, mailer_url_options).deliver
      notice = "The document has been sent to #{fact_check_request.email_address}"
      redirect_to admin_edition_path(@edition), notice: notice
    else
      alert = "There was a problem: #{fact_check_request.errors.full_messages.to_sentence}"
      redirect_to admin_edition_path(@edition), alert: alert
    end
  end

  def edit
  end

  def update
    if @fact_check_request.update_attributes(params[:fact_check_request])
      if @fact_check_request.requestor_contactable?
        Notifications.fact_check_response(@fact_check_request, mailer_url_options).deliver
      end
      notice = "Your feedback has been saved"
      redirect_to admin_fact_check_request_path(@fact_check_request), notice: notice
    else
      render "edition_unavailable"
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
      @edition = Edition.unscoped.find(@fact_check_request.edition_id)
    elsif request.host == 'whitehall.preview.alphagov.co.uk'
      temporary_redirect_from_preview_to_production
    else
      render text: "Not found", status: :not_found
    end
  end

  def temporary_redirect_from_preview_to_production
    redirect_to admin_fact_check_request_url(id: params[:id], host: 'whitehall.production.alphagov.co.uk')
  end

  def check_edition_availability
    if @edition.deleted?
      render "edition_unavailable"
    end
  end
end
