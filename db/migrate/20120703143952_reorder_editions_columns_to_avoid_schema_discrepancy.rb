class ReorderEditionsColumnsToAvoidSchemaDiscrepancy < ActiveRecord::Migration
  def change
    execute %{
      ALTER TABLE editions MODIFY national_statistic TINYINT(1) NOT NULL DEFAULT '0' AFTER publication_type_id
    }
  end
end
