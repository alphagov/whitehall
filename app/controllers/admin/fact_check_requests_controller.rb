class Admin::FactCheckRequestsController < Admin::BaseController
  before_filter :load_fact_check_request, only: [:show, :edit]

  def show
  end

  def create
    @edition = Edition.find(params[:edition_id])
    fact_check_request = @edition.fact_check_requests.build(params[:fact_check_request])
    if fact_check_request.save
      Notifications.fact_check(fact_check_request).deliver
      redirect_to edit_admin_edition_path(@edition),
        notice: "The policy has been sent to #{params[:fact_check_request][:email_address]}"
    else
      redirect_to edit_admin_edition_path(@edition),
        alert: "There was a problem: #{fact_check_request.errors.full_messages.to_sentence}"
    end
  end

  def edit
  end

  def update
    @fact_check_request = FactCheckRequest.find_by_token(params[:id])
    if @fact_check_request.update_attributes(params[:fact_check_request])
      redirect_to admin_edition_fact_check_request_path(@fact_check_request.edition, @fact_check_request),
                  notice: "Your feedback has been saved"
    end
  end

  private

  def load_fact_check_request
    @fact_check_request = FactCheckRequest.find_by_token(params[:id])
    if @fact_check_request
      @edition = @fact_check_request.edition
    else
      render text: "Not found", status: :not_found
    end
  end
end
