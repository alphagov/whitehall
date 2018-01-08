class Admin::TopicsController < Admin::ClassificationsController
  skip_before_action :authenticate_user!, only: [:show]
  skip_before_action :require_signin_permission!, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.json { render json: @classification, include: :classification_policies }
    end
  end

private

  def model_class
    Topic
  end
end
