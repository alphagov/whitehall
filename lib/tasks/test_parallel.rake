# By default, the parallel_test gem will use all available processors (real and virtual).
# You can override this by setting the PARALLEL_TEST_PROCESSORS environment variable.
namespace :test do
  desc "Run the entire test suite using the parallel runner"
  task :in_parallel => :environment do
    ENV['CUCUMBER_FORMAT'] = 'progress'
    ENV['RAILS_ENV'] = 'test'
    ['parallel:create', 'parallel:prepare', 'parallel:test', 'parallel:features', 'test:javascript', 'test:cleanup'].each do |task|
      Rake::Task[task].invoke
    end
  end
end
