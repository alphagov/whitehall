ActiveRecord::Base.connection.execute 'UPDATE roles SET content_id=UUID() where content_id IS NULL'
