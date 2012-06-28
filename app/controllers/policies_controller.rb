class PoliciesController < DocumentsController
  def index
    @policies = Policy.published.by_published_at
  end

  def show
    @policy = @document
    @countries = @policy.countries
    @recently_changed_documents = Edition.published.related_to(@policy).by_published_at
  end

  private

  def document_class
    Policy
  end
end