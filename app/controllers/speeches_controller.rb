class SpeechesController < DocumentsController
  def index
    @speeches = Speech.published.by_first_published_at
  end

  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
  end

  private

  def document_class
    Speech
  end
end