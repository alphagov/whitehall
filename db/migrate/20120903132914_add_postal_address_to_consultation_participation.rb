class AddPostalAddressToConsultationParticipation < ActiveRecord::Migration
  def change
    add_column :consultation_participations, :postal_address, :text
  end
end
