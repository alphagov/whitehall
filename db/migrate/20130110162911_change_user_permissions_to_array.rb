class ChangeUserPermissionsToArray < ActiveRecord::Migration
  class User < ActiveRecord::Base
    serialize :permissions
  end

  def up
    User.all.each do |user|
      if user.permissions.is_a?(Hash)
        user.permissions = user.permissions["Whitehall"]
        user.save(validate: false)
      end
    end
  end

  def down
    User.all.each do |user|
      unless user.permissions.nil?
        user.permissions = { "Whitehall" => user.permissions }
        user.save(validate: false)
      end
    end
  end
end
