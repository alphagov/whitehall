class RemoveOldUsers < ActiveRecord::Migration
  def up
    users_to_keep = Edition.includes(:authors).all.map(&:authors).flatten.uniq
    users_to_keep << User.find_by_name("GDS Inside Government Team")
    users_to_keep << User.find_by_name("Automatic Data Importer")
    users_to_keep << User.find_by_name("Scheduled Publishing Robot")
    users = User.arel_table
    users_to_destroy = User.where(users[:uid].eq(nil).or(users[:email].eq(nil)).or(users[:permissions].eq(nil))) - users_to_keep.compact
    users_to_destroy.map(&:destroy)
  end

  def down
    #noop
  end
end
