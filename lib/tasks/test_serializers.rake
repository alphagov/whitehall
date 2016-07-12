namespace :test do
  Rake::TestTask.new(serializers: "test:prepare") do |t|
    t.libs << 'test'
    t.test_files = FileList['test/unit/serializers/**/*_test.rb']
  end
  Rake::Task['test:serializers'].comment = "Test serializers (test/unit/serializers)"
end
