class SpeechesController < DocumentsController
  def index
    @speeches = Speech.published.by_first_published_at
  end

  def show
    @related_policies = @document.published_related_policies
    @policy_topics = @related_policies.map { |d| d.policy_topics }.flatten.uniq
  end

  private

  def document_class
    Speech
  end
end