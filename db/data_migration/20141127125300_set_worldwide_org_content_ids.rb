ActiveRecord::Base.connection.execute 'UPDATE worldwide_organisations SET content_id=UUID() where content_id IS NULL'
