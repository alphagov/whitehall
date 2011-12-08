class SpeechesController < DocumentsController
  def index
    @speeches = Speech.published.by_published_at
  end

  def show
    @related_policies = Policy.published.related_to(@document)
  end

  private

  def document_class
    Speech
  end
end