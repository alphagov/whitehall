class RenameResponsesToConsultationResponses < ActiveRecord::Migration[7.0]
  def change
    rename_table :responses, :consultation_responses
  end
end
