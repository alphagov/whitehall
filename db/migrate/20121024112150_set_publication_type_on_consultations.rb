class SetPublicationTypeOnConsultations < ActiveRecord::Migration
  def up
    execute %{
      UPDATE editions SET publication_type_id = 16
      WHERE type = 'Consultation'
    }
  end

  def down
  end
end
