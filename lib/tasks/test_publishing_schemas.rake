require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:publishing_schemas => "test:prepare") do |t|
    t.libs << 'test'
    t.test_files = `grep -rlE "valid_against_(links_)?schema" test`.lines.map(&:chomp)
  end

  Rake::Task['test:publishing_schemas'].comment = "Test publishing API presenters against external schemas"
end
