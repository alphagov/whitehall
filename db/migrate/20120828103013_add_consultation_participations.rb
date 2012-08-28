class AddConsultationParticipations < ActiveRecord::Migration
  def change
    add_column :editions, :consultation_participation_link_url, :string
    add_column :editions, :consultation_participation_link_text, :string
  end
end
