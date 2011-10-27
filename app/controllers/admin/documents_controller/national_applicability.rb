module Admin::DocumentsController::NationalApplicability
  extend ActiveSupport::Concern

  included do
    before_filter :build_nation_inapplicabilities, only: [:new, :edit]
  end

  def create
    nation_inapplicabilities_attributes = params[:document].delete(:nation_inapplicabilities_attributes) || {}
    @document = document_class.new(params[:document].merge(author: current_user))
    if @document.valid?
      @document.nation_inapplicabilities_attributes = nation_inapplicabilities_attributes
    end
    if @document.save
      redirect_to admin_document_path(@document), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_nation_inapplicabilities
      populate_nation_inapplicabilities_from(nation_inapplicabilities_attributes)
      render action: "new"
    end
  end

  def update
    nation_inapplicabilities_attributes = params[:document].delete(:nation_inapplicabilities_attributes) || {}
    @document.attributes = params[:document]
    if @document.valid?
      @document.nation_inapplicabilities_attributes = nation_inapplicabilities_attributes
    end
    if @document.save
      redirect_to admin_document_path(@document),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      build_nation_inapplicabilities
      populate_nation_inapplicabilities_from(nation_inapplicabilities_attributes)
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_document = Document.find(params[:id])
    @document.lock_version = @conflicting_document.lock_version
    build_nation_inapplicabilities
    populate_nation_inapplicabilities_from(nation_inapplicabilities_attributes)
    render action: "edit"
  end

  private

  def build_nation_inapplicabilities
    @document.build_nation_applicabilities_for_all_nations
  end

  def populate_nation_inapplicabilities_from(attributes)
    attributes.each do |index, hash|
      inapplicability = @document.nation_inapplicabilities[index.to_i]
      inapplicability[:_destroy] = hash[:_destroy]
      inapplicability[:alternative_url] = hash[:alternative_url]
    end
  end

end