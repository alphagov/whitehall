namespace :document_collection do
  desc "Add content published in a different GOV.UK app to a document collection group"
  task :add_non_whitehall_link_to_group, %i[content_id group_id] => :environment do |_, args|
    content_item = Services.publishing_api.get_content(args[:content_id])
    group = DocumentCollectionGroup.find(args[:group_id])
    non_whitehall_link = DocumentCollectionNonWhitehallLink.new(
      content_item.to_h.slice("content_id", "title", "base_path", "publishing_app")
    )
    group.non_whitehall_links << non_whitehall_link
  end
end
