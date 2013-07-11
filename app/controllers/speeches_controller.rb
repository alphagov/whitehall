class SpeechesController < DocumentsController
  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
    set_slimmer_organisations_header(@document.organisations)
    set_slimmer_page_owner_header(@document.lead_organisations.first)
    set_meta_description(@document.summary)
  end

  private

  def document_class
    Speech
  end
end
