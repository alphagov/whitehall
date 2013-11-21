class SpeechesController < DocumentsController
  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
    set_slimmer_headers_for_document(@document)
    set_meta_description(@document.summary)
  end

  private

  def document_class
    Speech
  end
end
