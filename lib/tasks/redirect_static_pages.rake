desc "Redirect static pages in publishing api, remove from rummager. This is called manually when needed."
task redirect_static_pages: [:environment] do
  puts "redirecting static pages..."
  RedirectStaticPages.new.redirect
  puts "FINISHED"
end
