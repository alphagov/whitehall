class Admin::ConsultationResponsesController < Admin::EditionsController
  include Admin::EditionsController::Attachments

private
  def edition_class
    ConsultationResponse
  end

end
