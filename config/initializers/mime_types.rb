# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.unregister :html
Mime::Type.register "text/html", :html, %w( application/xhtml+xml application/vnd.wap.xhtml+xml), %w( xhtml )
