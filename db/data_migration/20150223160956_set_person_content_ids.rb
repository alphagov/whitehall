ActiveRecord::Base.connection.execute 'UPDATE people SET content_id=UUID() where content_id IS NULL'
