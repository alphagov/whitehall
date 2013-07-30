class Admin::ResponsesController < Admin::BaseController
  before_filter :find_consultation
  before_filter :limit_edition_access!
  before_filter :enforce_edition_permissions!
  before_filter :prevent_modification_of_unmodifiable_edition
  before_filter :find_response, only: [:edit, :update]

  def show
    @response = response_class.find_by_edition_id(@edition) || response_class.new(published_on: Date.today)
  end

  def create
    @response = response_class.new(response_params)
    @response.consultation = @edition
    if @response.save
      redirect_to [:admin, @edition, @response.singular_routing_symbol], notice: "#{@response.friendly_name.capitalize} saved"
    else
      render :show
    end
  end

  def edit
  end

  def update
    if @response.update_attributes(response_params)
      redirect_to [:admin, @edition, @response.singular_routing_symbol], notice: "#{@response.friendly_name.capitalize} updated"
    else
      render :edit
    end
  end

  private

  def find_consultation
    @edition = Consultation.find(params[:consultation_id])
  end

  def find_response
    @response = response_class.find_by_edition_id(@edition)
    raise(ActiveRecord::RecordNotFound, "Could not find Response for Consulatation with ID #{@edition.id}") unless @response
  end

  def enforce_edition_permissions!
    enforce_permission!(:update, @edition)
  end

  def response_class
    case params[:type]
      when 'ConsultationOutcome' then ConsultationOutcome
      when 'ConsultationPublicFeedback' then ConsultationPublicFeedback
    end
  end

  def response_params
    params[:consultation_outcome] || params[:consultation_public_feedback]
  end
end
