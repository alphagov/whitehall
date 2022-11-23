class Admin::FactCheckRequestsController < Admin::BaseController
  before_action :load_fact_check_request, only: %i[show edit update]
  before_action :load_edition, only: %i[index create new]
  before_action :enforce_permissions!, only: %i[new create]
  before_action :limit_edition_access!, only: %i[index new create]
  before_action :check_edition_availability, only: %i[show edit]
  skip_before_action :authenticate_user!, only: %i[show edit update]
  layout :get_layout

  def show
    render_design_system("show", "show_legacy", next_release: true)
  end

  def create
    attributes = fact_check_request_params.merge(requestor: current_user)
    fact_check_request = @edition.fact_check_requests.build(attributes)

    if @edition.deleted?
      render_design_system("edition_unavailable", "legacy_edition_unavailable", next_release: true)
    elsif fact_check_request.save
      MailNotifications.fact_check_request(fact_check_request, mailer_url_options).deliver_now
      notice = "The document has been sent to #{fact_check_request.email_address}"
      redirect_to admin_edition_path(@edition), notice:
    else
      alert = "There was a problem: #{fact_check_request.errors.full_messages.to_sentence}"
      redirect_to admin_edition_path(@edition), alert:
    end
  end

  def edit
    render_design_system("edit", "edit_legacy", next_release: true)
  end

  def update
    if @fact_check_request.update(fact_check_request_params)
      if @fact_check_request.requestor_contactable?
        MailNotifications.fact_check_response(@fact_check_request, mailer_url_options).deliver_now
      end
      notice = "Thanks for submitting your response to this fact checking request. Your feedback has been saved."
      redirect_to admin_fact_check_request_path(@fact_check_request), notice:
    else
      render_design_system("edition_unavailable", "legacy_edition_unavailable", next_release: true)
    end
  end

private

  def get_layout
    if preview_design_system?(next_release: true)
      "design_system"
    else
      "admin"
    end
  end

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
    options[:protocol] = request.protocol unless request.protocol == "http://"
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
      render_design_system("edition_unavailable", "legacy_edition_unavailable", next_release: true)
    end
  end
end
