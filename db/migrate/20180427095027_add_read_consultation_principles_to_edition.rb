class AddReadConsultationPrinciplesToEdition < ActiveRecord::Migration[5.0]
  def change
    add_column :editions, :read_consultation_principles, :boolean, default: false
  end
end
