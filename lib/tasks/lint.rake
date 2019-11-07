desc "Run govuk-lint-ruby"
task :lint do |_task, _args|
  system "rubocop --parallel app lib test"
end
