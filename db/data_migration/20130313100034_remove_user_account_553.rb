# Replace all mentions of user 553 to user 648. See ticket:
# https://www.pivotaltracker.com/story/show/46035207

[
  %w(versions whodunnit),
  %w(edition_authors user_id),
  %w(user_world_locations user_id),
  %w(editorial_remarks author_id),
  %w(fact_check_requests requestor_id),
  %w(imports creator_id),
  %w(recent_edition_openings editor_id)
].each do |table, column|
  ActiveRecord::Base.connection.execute %{
    UPDATE #{table} SET #{column}="648" WHERE #{column}="553";
  }
end

ActiveRecord::Base.connection.execute "DELETE FROM users WHERE id=553;"
