conn = ActiveRecord::Base.connection

conn.execute(<<~SQL)
  UPDATE documents
  SET document_type = 'PlanForChangeLandingPage'
  WHERE document_type = 'LandingPage';
SQL

conn.execute(<<~SQL)
  UPDATE editions
  SET type = 'PlanForChangeLandingPage'
  WHERE document_id IN (
    SELECT id FROM documents WHERE document_type = 'PlanForChangeLandingPage'
  );
SQL
