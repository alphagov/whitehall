module Admin::DocumentsController::NationalApplicability
  extend ActiveSupport::Concern

  included do
    before_filter :build_nation_inapplicabilities, only: [:new, :edit]
  end

  def create
    params[:document][:nation_inapplicabilities_attributes] ||= {}
    @document = document_class.new(params[:document].except(
      :nation_inapplicabilities_attributes,
      :attach_file
    ).merge(creator: current_user))
    if @document.save
      if @document.update_attributes(params[:document])
        redirect_to admin_document_path(@document), notice: "The document has been saved"
      else
        process_nation_inapplicabilities
        render action: "edit"
      end
    else
      flash.now[:alert] = "There are some problems with the document"
      @document.nation_inapplicabilities_attributes = params[:document][:nation_inapplicabilities_attributes]
      process_nation_inapplicabilities
      render action: "new"
    end
  end

  def update
    params[:document][:nation_inapplicabilities_attributes] ||= {}
    if @document.edit_as(current_user, params[:document])
      redirect_to admin_document_path(@document),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      process_nation_inapplicabilities
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_document = Document.find(params[:id])
    @document.lock_version = @conflicting_document.lock_version
    process_nation_inapplicabilities
    render action: "edit"
  end

  private

  def process_nation_inapplicabilities
    set_nation_inapplicabilities_destroy_checkbox_state
    build_nation_inapplicabilities
  end

  def set_nation_inapplicabilities_destroy_checkbox_state
    @document.nation_inapplicabilities.each { |ni| ni[:_destroy] = ni._destroy ? "1" : "0" }
  end

  def build_nation_inapplicabilities
    @document.build_nation_applicabilities_for_all_nations
  end
  
end