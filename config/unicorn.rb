app_root = File.dirname(File.dirname(__FILE__))
log_path = app_root.gsub %r{/var/apps/}, "/var/log/"
stderr_path "#{log_path}/stderr.log"
stdout_path "#{log_path}/stdout.log"
working_directory app_root
worker_processes 4
