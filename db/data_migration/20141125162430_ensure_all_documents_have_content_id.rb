ActiveRecord::Base.connection.execute 'UPDATE documents SET content_id=UUID() where content_id IS NULL'
