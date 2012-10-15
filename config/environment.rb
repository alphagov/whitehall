# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Whitehall::Application.initialize!

# Register WAP request types
Mime::Type.register 'application/vnd.wap.xhtml+xml', :wap
