namespace :migrate do
  desc "Move content from one role to another (DANGER!)."
  task :role_content, %i[old_role new_role] => :environment do |_task, args|
    old_role = args[:old_role]
    new_role = args[:new_role]
    old_role = Role.find_by!(slug: old_role)
    new_role = Role.find_by!(slug: new_role)

    old_role.speeches.each do |speech|
      speech.role_appointment = new_role.role_appointments.last
      speech.save!
    end
  end
end
