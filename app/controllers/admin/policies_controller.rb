class Admin::PoliciesController < Admin::EditionsController
  before_filter :forbid_access_to_non_admins!, except: [:index, :show, :topics]

  def topics
    topics = ClassificationPolicy.where(policy_content_id: params[:policy_id])
    topics = topics.map(&:classification_id)

    respond_to do |format|
      format.json { render json: { topics: topics } }
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
        alert: "Policies are no longer changed via Whitehall, please see contact GDS"
    end
  end
end
