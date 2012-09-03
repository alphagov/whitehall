class MoveConsultationResponseBodiesToTheSummary < ActiveRecord::Migration
  def up
    update "UPDATE editions SET summary = body, body = null WHERE type = 'ConsultationResponse'"
  end

  def down
    update "UPDATE editions SET body = summary, summary = null WHERE type = 'ConsultationResponse'"
  end
end
