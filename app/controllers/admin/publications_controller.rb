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
    if values.all?(&:blank?)
      publication_date = nil
    else
      publication_date = Date.new(*values.map { |v| v.blank? ? 1 : v.to_i })
    end
    params[:document][:publication_date] ||= publication_date
  end
end