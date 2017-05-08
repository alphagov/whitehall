# Use this rake task to run performance tests against the "benchmark"
# environment. See test/benchmark_helper.rb for more details.
require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:alt_benchmarks => ['test:benchmark_mode']) do |t|
    t.libs << 'test'
    t.pattern = 'test/performance/**/*_test.rb'
  end
end
