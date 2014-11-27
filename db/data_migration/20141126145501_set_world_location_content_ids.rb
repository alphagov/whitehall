ActiveRecord::Base.connection.execute 'UPDATE world_locations SET content_id=UUID() where content_id IS NULL'
