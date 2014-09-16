class Admin::PoliciesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  def topics
    respond_to do |format|
      presenters = @edition.topics.map { |topic| TopicPresenter.new(topic) }
      format.json { render json: { topics: presenters } }
    end
  end

  private

  def edition_class
    Policy
  end

  def document_can_be_previously_published
    false
  end
end
