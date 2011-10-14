begin
  Nation.ensure_existence!
rescue ActiveRecord::StatementInvalid => e
  raise e unless e.message =~ /SHOW FIELDS FROM `nations`/
end