namespace :policy_area do
  desc 'Remove and redirect policy area'
  task :remove_and_redirect, %i(content_id redirect_path) => :environment do |_t, args|
    policy_area = Topic.find_by(content_id: args[:content_id])
    policy_area.unpublish_and_redirect(args[:redirect_path])
  end
end
