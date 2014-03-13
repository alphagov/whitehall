# By default, the parallel_test gem will use all available processors (real and virtual).
# You can override this by setting the PARALLEL_TEST_PROCESSORS environment variable.
# We use the test-queue gem for running units, functionals and integration tests as it is
# faster than parallel_test and has better logging output.
namespace :test do
  desc "Run the entire test suite using parallel test runners"
  task :in_parallel => :environment do
    ENV['CUCUMBER_FORMAT'] = 'progress'
    ENV['RAILS_ENV'] = 'test'

    setup_tasks = ['parallel:drop', 'parallel:create', 'parallel:load_schema']
    test_tasks = ['test_queue', 'shared_mustache:compile', 'parallel:features', 'test:javascript']
    cleanup_tasks = ['test:cleanup']

    setup_tasks.each { |task| Rake::Task[task].invoke }
    ParallelTests::Tasks.check_for_pending_migrations

    test_tasks.each { |task| Rake::Task[task].invoke }

    cleanup_tasks.each { |task| Rake::Task[task].invoke }
  end
end

# To get the databases setup for parallel tests, run the following rake command:
#   RAILS_ENV=test rake parallel:create parallel:prepare
desc "Runs units, functionals and integrations together using the test-queue runner. By default it uses all available processors. Set TEST_QUEUE_WORKERS to override."
task :test_queue do
  files = Dir.chdir('test') do
    Dir['unit/**/*_test.rb', 'functional/**/*_test.rb', 'integration/**/*_test.rb']
  end
  # Ensure the number of workers matches the number of PARALLEL_TEST_PROCESSORS
  ENV['TEST_QUEUE_WORKERS'] ||= ENV['PARALLEL_TEST_PROCESSORS']
  puts "Running unit, functional and integration tests from #{files.size} files across #{ENV['TEST_QUEUE_WORKERS']} processors."
  command = "./script/test_queue"
  abort unless system(command, *files)
end
