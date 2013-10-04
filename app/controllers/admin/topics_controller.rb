class Admin::TopicsController < Admin::ClassificationsController

  private

  def model_class
    Topic
  end
end
