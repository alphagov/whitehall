namespace :test do
  Rake::TestTask.new(:publishing_schemas => "test:prepare") do |t|
    t.libs << 'test'
    t.test_files = FileList['test/unit/presenters/publishing_api_presenters/*_test.rb']
  end
  Rake::Task['test:publishing_schemas'].comment = "Test publishing API presenters against external schemas"
end
