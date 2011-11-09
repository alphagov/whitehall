class SpeechesController < DocumentsController
  def index
    @speeches = Speech.published.by_publication_date
  end

  private

  def document_class
    Speech
  end
end