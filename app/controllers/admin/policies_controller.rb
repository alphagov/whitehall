class Admin::PoliciesController < Admin::DocumentsController

  before_filter :build_nation_inapplicabilities, only: [:new, :edit]

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
      nation_inapplicabilities_attributes.each do |index, attributes|
        @document.nation_inapplicabilities[index.to_i][:_destroy] = attributes[:_destroy]
        @document.nation_inapplicabilities[index.to_i][:alternative_url] = attributes[:alternative_url]
      end
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
      nation_inapplicabilities_attributes.each do |index, attributes|
        @document.nation_inapplicabilities[index.to_i][:_destroy] = attributes[:_destroy]
        @document.nation_inapplicabilities[index.to_i][:alternative_url] = attributes[:alternative_url]
      end
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This document has been saved since you opened it"
    @conflicting_document = Document.find(params[:id])
    @document.lock_version = @conflicting_document.lock_version
    render action: "edit"
  end

  private

  def document_class
    Policy
  end

  def build_nation_inapplicabilities
    (Nation.all.map(&:id) - @document.nation_inapplicabilities.map(&:nation_id)).each do |nation_id|
      @document.nation_inapplicabilities.build(nation_id: nation_id)
    end
    @document.nation_inapplicabilities.sort_by! { |na| na.nation_id }
  end
end