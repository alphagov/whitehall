task :publish_static_pages => [:environment] do
  PublishStaticPages.new.publish
end
