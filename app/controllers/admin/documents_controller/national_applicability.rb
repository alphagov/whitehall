module Admin::DocumentsController::NationalApplicability
  extend ActiveSupport::Concern

  included do
    before_filter :build_document, only: [:new]

    before_filter :build_nation_inapplicabilities, only: [:new, :edit]
  end

  def create
    params[:document][:nation_inapplicabilities_attributes] ||= {}
    @document = document_class.new(params[:document].merge(creator: current_user))
    if @document.save
      redirect_to admin_document_path(@document), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_document_attachment
      build_image
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
      build_document_attachment
      build_image
      process_nation_inapplicabilities
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    build_document_attachment
    build_image
    @conflicting_document = Edition.find(params[:id])
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

  def build_document_attachment
  end
end