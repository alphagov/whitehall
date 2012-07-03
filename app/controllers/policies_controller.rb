class PoliciesController < DocumentsController
  before_filter :find_document, only: [:show, :activity]

  def index
    @policies = Policy.published.by_published_at
  end

  def show
    @policy = @document
    @countries = @policy.countries
    @topics = @policy.topics
  end

  def activity
    @policy = @document
    @recently_changed_documents = Edition.published.related_to(@policy).by_published_at
  end

  private

  def document_class
    Policy
  end
end