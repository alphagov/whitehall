class Admin::PoliciesController < Admin::EditionsController
  before_filter :forbid_access_to_non_admins!, except: [:index, :show, :topics]

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

  def forbid_access_to_non_admins!
    unless can?(:modify, Policy)
      redirect_to admin_policy_path(@edition),
        alert: "Policies are no longer changed via Whitehall, please see the Policies Publisher"
    end
  end
end
