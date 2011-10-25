require 'socket'

namespace :test do

  desc "Run javascript tests"
  task :javascript => :environment do
    test_port = 3100
    pid_file = Rails.root.join('tmp', 'pids', 'javascript_tests.pid')

    if File.exists?(pid_file)
      STDERR.puts "It looks like the javascript test server is running with pid #{File.read(pid_file)}."
      STDERR.puts "Please kill the server, remove the pid file from #{pid_file} and re-run this task:"
      STDERR.puts "  $ kill -KILL `cat #{pid_file}` && rm #{pid_file}"
      exit 1
    end

    puts "Starting the test server on port #{test_port}"
    `cd #{Rails.root} && script/rails server -p #{test_port} --daemon --environment=test --pid=#{pid_file}`

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

    # linux needs to run phantom through windowing server
    # apt-get install xvfb
    if RUBY_PLATFORM =~ /linux/
      command = "xvfb-run " + command
    end

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

    exit test_result
  end

end

task :default => "test:javascript"