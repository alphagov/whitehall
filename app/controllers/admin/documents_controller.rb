class Admin::DocumentsController < Admin::BaseController
private

  def documents
    Document.limit(500).order('-documents.id')
  end
  helper_method :documents

  def document
    Document.find(params[:id])
  end

  def latest_edition
    editions[0]
  end

  def previous_editions
    editions[1..-1]
  end

  helper_method :document
  helper_method :documents
  helper_method :latest_edition
  helper_method :previous_editions

  def editions
    document.editions.order('id desc')
  end
end
