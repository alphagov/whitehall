require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(presenters: "test:prepare") do |t|
    t.libs << 'test'
    t.test_files = FileList['test/unit/presenters/**/*_test.rb']
  end
  Rake::Task['test:presenters'].comment = "Test presenters (test/unit/presenters)"
end
