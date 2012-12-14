module Admin::EditionsController::NationalApplicability
  extend ActiveSupport::Concern

  included do
    skip_before_filter :build_edition, except: [:new]

    before_filter :build_nation_inapplicabilities, only: [:new, :edit]
  end

  def create
    params[:edition][:nation_inapplicabilities_attributes] ||= {}
    @edition = edition_class.new(params[:edition].merge(creator: current_user))
    if @edition.save
      redirect_to admin_edition_path(@edition), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_edition_dependencies
      process_nation_inapplicabilities
      render action: "new"
    end
  end

  def update
    params[:edition][:nation_inapplicabilities_attributes] ||= {}
    if @edition.edit_as(current_user, params[:edition])
      redirect_to admin_edition_path(@edition),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_edition_dependencies
      process_nation_inapplicabilities
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    build_edition_dependencies
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
end
