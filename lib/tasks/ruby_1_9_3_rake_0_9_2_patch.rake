# Patch for https://github.com/jimweirich/rake/issues/51

if Rake::VERSION == "0.9.2" && RUBY_VERSION == "1.9.3"
  %w[ units functionals integration ].each do |name|
    path = name.sub(/s$/, "")

    task("test:#{name}").clear_actions

    Rake::TestTask.new("test:#{name}") do |t|
      t.libs << "test"
      t.test_files = Dir["test/#{path}/**/*_test.rb"]
    end
  end
end
