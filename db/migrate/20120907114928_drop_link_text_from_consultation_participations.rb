class DropLinkTextFromConsultationParticipations < ActiveRecord::Migration
  def change
    remove_column :consultation_participations, :link_text
  end
end
