Edition.connection.execute <<-SQL
  UPDATE documents SET change_note = NULL WHERE type = 'Policy'
SQL
