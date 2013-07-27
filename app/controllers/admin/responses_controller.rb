class Admin::ResponsesController < Admin::BaseController
  before_filter :find_consultation
  before_filter :limit_edition_access!
  before_filter :enforce_edition_permissions!
  before_filter :prevent_modification_of_unmodifiable_edition
  before_filter :find_response, only: [:edit, :update]

  def show
    @response = @edition.response
  end

  def new
    @response = @edition.build_response(published_on: Date.today)
  end

  def create
    @response = @edition.build_response(params[:response])
    if @response.save
      redirect_to admin_consultation_response_path, notice: 'Response saved'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @response.update_attributes(params[:response])
      redirect_to admin_consultation_response_path, notice: 'Response updated'
    else
      render :edit
    end
  end

  private

  def find_consultation
    @edition = Consultation.find(params[:consultation_id])
  end

  def find_response
    @response = @edition.response
    raise(ActiveRecord::RecordNotFound, "Could not find Response for Consulatation with ID #{@edition.id}") unless @response
  end

  def enforce_edition_permissions!
    enforce_permission!(:update, @edition)
  end
end
