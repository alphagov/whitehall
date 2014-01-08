require 'socket'

namespace :test do

  desc "Run javascript tests"
  task :javascript => :environment do
    phantomjs_requirement = Gem::Requirement.new(">= 1.3.0")
    phantomjs_version = Gem::Version.new(`phantomjs --version`.match(/\d+\.\d+\.\d+/)[0]) rescue Gem::Version.new("0.0.0")
    unless phantomjs_requirement.satisfied_by?(phantomjs_version)
      STDERR.puts "Your version of phantomjs (v#{phantomjs_version}) is not compatible with the current phantom-driver.js."
      STDERR.puts "Please upgrade your version of phantomjs to #{phantomjs_requirement} and re-run this task."
      exit 1
    end

    test_port = 3100
    pid_file = Rails.root.join('tmp', 'pids', 'javascript_tests.pid')

    if File.exists?(pid_file)
      STDERR.puts "It looks like the javascript test server is running with pid #{File.read(pid_file)}."
      STDERR.puts "Please kill the server, remove the pid file from #{pid_file} and re-run this task:"
      STDERR.puts "  $ kill -KILL `cat #{pid_file}` && rm #{pid_file}"
      exit 1
    end

    puts "Compiling the mustache templates"
    Rake::Task["shared_mustache:compile"].invoke

    puts "Starting the test server on port #{test_port}"
    `cd #{Rails.root} && rails server -p #{test_port} --daemon --environment=test --pid=#{pid_file}`

    puts "Waiting for the server to come up"
    not_connected = true
    while (not_connected) do
      begin
        TCPSocket.new("127.0.0.1", test_port)
        not_connected = false
        puts "Server is up and ready"
      rescue Errno::ECONNREFUSED
        sleep 1
      end
    end

    runner = "http://127.0.0.1:#{test_port}/test/qunit"
    phantom_driver = Rails.root.join('test', 'javascripts', 'support', 'phantom-driver.js')

    command = "phantomjs #{phantom_driver} #{runner}"

    IO.popen(command) do |test|
      puts test.read
    end

    # grab the exit status of phantomjs
    # this will be the result of the tests
    # it is important to grab it before we
    # exit the server otherwise $? will be overwritten.
    test_result = $?.exitstatus

    puts "Stopping the server"
    if File.exist?(pid_file)
      `kill -KILL #{File.read(pid_file)}`
      `rm #{pid_file}`
    end

    puts "Removing compiled mustache templates"
    Rake::Task["shared_mustache:clean"].invoke

    exit test_result
  end

end

task :default => "test:javascript"
