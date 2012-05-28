module Admin::EditionsController::NationalApplicability
  extend ActiveSupport::Concern

  included do
    before_filter :build_edition, only: [:new]

    before_filter :build_nation_inapplicabilities, only: [:new, :edit]
  end

  def create
    params[:document][:nation_inapplicabilities_attributes] ||= {}
    @edition = document_class.new(params[:document].merge(creator: current_user))
    if @edition.save
      redirect_to admin_document_path(@edition), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_edition_attachment
      build_image
      process_nation_inapplicabilities
      render action: "new"
    end
  end

  def update
    params[:document][:nation_inapplicabilities_attributes] ||= {}
    if @edition.edit_as(current_user, params[:document])
      redirect_to admin_document_path(@edition),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_edition_attachment
      build_image
      process_nation_inapplicabilities
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    build_edition_attachment
    build_image
    @conflicting_edition = Edition.find(params[:id])
    @edition.lock_version = @conflicting_edition.lock_version
    process_nation_inapplicabilities
    render action: "edit"
  end

  private

  def process_nation_inapplicabilities
    set_nation_inapplicabilities_destroy_checkbox_state
    build_nation_inapplicabilities
  end

  def set_nation_inapplicabilities_destroy_checkbox_state
    @edition.nation_inapplicabilities.each { |ni| ni[:_destroy] = ni._destroy ? "1" : "0" }
  end

  def build_nation_inapplicabilities
    @edition.build_nation_applicabilities_for_all_nations
  end

  def build_edition_attachment
  end
end