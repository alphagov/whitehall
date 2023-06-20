class RenameAttachableTypesFromResponsesToConsultationResponses < ActiveRecord::Migration[7.0]
  def up
    execute "UPDATE attachments SET attachable_type = 'ConsultationResponse' WHERE attachable_type = 'Response'"
  end

  def down
    execute "UPDATE attachments SET attachable_type = 'Response' WHERE attachable_type = 'ConsultationResponse'"
  end
end
