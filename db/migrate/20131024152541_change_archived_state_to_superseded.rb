class ChangeArchivedStateToSuperseded < ActiveRecord::Migration
  def up
    execute "UPDATE editions SET state = 'superseded' WHERE state = 'archived'"
  end

  def down
    execute "UPDATE editions SET state = 'archived' WHERE state = 'superseded'"
  end
end
