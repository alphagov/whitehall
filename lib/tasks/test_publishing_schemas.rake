require "rake/testtask"

namespace :test do
  Rake::TestTask.new(publishing_schemas: "test:prepare") do |t|
    t.libs << "test"
    t.test_files = FileList["test/unit/finder_schema_validation_test.rb", "test/unit/presenters/publishing_api/*_test.rb"]
    t.warning = false
  end

  Rake::Task["test:publishing_schemas"].comment = "Test publishing API presenters against external schemas"
end
