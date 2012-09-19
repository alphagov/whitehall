class RemoveEditorFlagFromUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    serialize :permissions, Hash
  end

  def up
    User.all.each do |user|
      if user.departmental_editor?
        permissions = user.permissions['Whitehall']
        if permissions && !permissions.include?('Editor')
          user.permissions['Whitehall'] = (permissions << 'Editor')
          user.save!
        end
      end
    end
    remove_column :users, :departmental_editor
  end
end
