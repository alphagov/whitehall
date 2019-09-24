puts "Cleaning-up erroneously synced users who do not have not accessed Whitehall in the past."

users_to_delete = User.where("created_at >= ?", Time.zone.parse("27-Nov-2014 10:50")).select { |user| user.permissions.blank? }
number_of_users_deleted = User.delete_all(id: users_to_delete.map(&:id))

puts "Done. Deleted #{number_of_users_deleted} users."
