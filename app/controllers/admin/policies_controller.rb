class Admin::PoliciesController < Admin::BaseController
  def topics
    topics = ClassificationPolicy.where(policy_content_id: params[:policy_id])
    topics = topics.map(&:classification_id)

    respond_to do |format|
      format.json { render json: { topics: topics } }
    end
  end
end
