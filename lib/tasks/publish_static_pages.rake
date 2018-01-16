desc "Publish of static pages to rummager and publishing api. This is called manually when needed."
task publish_static_pages: [:environment] do
  PublishStaticPages.new.publish
end
