class Admin::TopicsController < Admin::ClassificationsController

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
