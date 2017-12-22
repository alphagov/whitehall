class Admin::FactCheckRequestsController < Admin::BaseController
  before_action :load_fact_check_request, only: %i[show edit update]
  before_action :load_edition, only: [:create]
  before_action :enforce_permissions!, only: [:create]
  before_action :limit_edition_access!, only: [:create]
  before_action :check_edition_availability, only: %i[show edit]
  skip_before_action :authenticate_user!, except: [:create]

  def show; end

  def create
    attributes = fact_check_request_params.merge(requestor: current_user)
    fact_check_request = @edition.fact_check_requests.build(attributes)
    if @edition.deleted?
      render "edition_unavailable"
    elsif fact_check_request.save
      Notifications.fact_check_request(fact_check_request, mailer_url_options).deliver_now
      notice = "The document has been sent to #{fact_check_request.email_address}"
      redirect_to admin_edition_path(@edition), notice: notice
    else
      alert = "There was a problem: #{fact_check_request.errors.full_messages.to_sentence}"
      redirect_to admin_edition_path(@edition), alert: alert
    end
  end

  def edit; end

  def update
    if @fact_check_request.update_attributes(fact_check_request_params)
      if @fact_check_request.requestor_contactable?
        Notifications.fact_check_response(@fact_check_request, mailer_url_options).deliver_now
      end
      notice = "Your feedback has been saved"
      redirect_to admin_fact_check_request_path(@fact_check_request), notice: notice
    else
      render "edition_unavailable"
    end
  end

private

  def fact_check_request_params
    params.require(:fact_check_request).permit(
      :email_address, :comments, :instructions
    )
  end

  def load_edition
    @edition = Edition.unscoped.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:make_fact_check, @edition)
  end

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
    else
      render plain: "Not found", status: :not_found
    end
  end

  def check_edition_availability
    if @edition.deleted?
      render "edition_unavailable"
    end
  end
end
