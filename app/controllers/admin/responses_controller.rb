class Admin::ResponsesController < Admin::BaseController
  before_filter :find_consultation
  before_filter :find_response, only: [:edit, :update]

  def show
    @response = @consultation.response
  end

  def new
    @response = @consultation.build_response(published_on: Date.today)
  end

  def create
    @response = @consultation.build_response(params[:response])
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
    @consultation = Consultation.find(params[:consultation_id])
  end

  def find_response
    @response = @consultation.response
    raise(ActiveRecord::RecordNotFound, "Could not find Response for Consulatation with ID #{@consultation.id}") unless @response
  end
end
