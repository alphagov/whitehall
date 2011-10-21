class Admin::SpeechesController < Admin::DocumentsController
  private

  def document_class
    Speech
  end
end