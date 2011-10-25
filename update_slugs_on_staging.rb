require File.expand_path('../config/environment', __FILE__)

[Organisation, Role, SupportingDocument, Topic].each do |klass|
  # We need to temporarily override #should_generate_new_friendly_id? so that we can generate slugs for existing objects
  klass.class_eval do
    def should_generate_new_friendly_id?
      super
    end
  end

  # Re-save each of the objects to force slug creation
  puts "Updating #{klass.to_s.tableize}"
  klass.all.each { |object| object.save }
end

puts "Updating documents"
Document.all.each do |document|
  identity = document.document_identity
  identity.sluggable_string = document.title
  identity.save
end