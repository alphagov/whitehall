class Admin::PoliciesController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability
  before_filter :build_image, only: [:new, :edit]

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
end
