force_publish_robot_user = ForcePublisher::Worker.new.user
if force_publish_robot_user.nil?
  puts "User for Force Publisher is not present! - can't escalate permissions!"
else
  puts "Allowing User for Force Publisher (#{force_publish_robot_user.name}[#{force_publish_robot_user.id}]) to force publish anything"
  force_publish_robot_user.permissions << User::Permissions::FORCE_PUBLISH_ANYTHING
  force_publish_robot_user.save!
end
