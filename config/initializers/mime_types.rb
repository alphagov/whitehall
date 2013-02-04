# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.unregister :html
Mime::Type.register "text/html", :html, %w( application/xhtml+xml application/vnd.wap.xhtml+xml), %w( xhtml )
Mime::Type.register "text/rtf", :rtf

Mime::Type.register "image/jpeg", :jpg, [], %w( jpeg )
Mime::Type.register "image/png", :png

Mime::Type.register "application/zip", :zip
Mime::Type.register "application/pdf", :pdf
Mime::Type.register "application/msword", :doc
Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx
Mime::Type.register "application/vnd.ms-excel", :xls
Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
Mime::Type.register "application/vnd.ms-powerpoint", :ppt
Mime::Type.register "application/vnd.openxmlformats-officedocument.presentationml.presentation", :pptx

Mime::Type.register "application/vnd.oasis.opendocument.text", :odt
Mime::Type.register "application/vnd.oasis.opendocument.spreadsheet", :ods

Mime::Type.register "application/rdf+xml", :rdf
