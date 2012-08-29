class AddEmailToConsultationParticipations < ActiveRecord::Migration
  def change
    add_column :consultation_participations, :email, :string
  end
end
