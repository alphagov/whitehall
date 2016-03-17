sql = <<-SQL
  UPDATE editions
  SET need_ids = NULL
  WHERE need_ids = "--- []\n";
SQL

ActiveRecord::Base.connection.execute(sql)
