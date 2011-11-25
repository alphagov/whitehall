class Admin::PublicationsController < Admin::DocumentsController
  include Admin::DocumentsController::NationalApplicability

  before_filter :pre_process_publication_date, only: [:create, :update]

  private

  def document_class
    Publication
  end

  def pre_process_publication_date
    values = (1..3).map do |i|
      params[:document].delete("publication_date(#{i}i)")
    end
    publication_date = values.all? ? Date.parse(values.join("-")) : nil
    params[:document][:publication_date] ||= publication_date
  end
end