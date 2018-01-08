namespace :test do
  desc "Run javascript tests"
  task javascript: :environment do
    puts "Compiling the mustache templates"
    Rake::Task["shared_mustache:compile"].invoke

    begin
      Rake::Task[:teaspoon].invoke
    ensure
      puts "Removing compiled mustache templates"
      Rake::Task["shared_mustache:clean"].invoke
    end
  end
end

task default: "test:javascript"
