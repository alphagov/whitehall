object @document

attributes :title, :slug
node(:url) { |o| public_document_url(o) }

child :attachments => :attachments do
  attributes :title, :content_type, :file_size, :url
  node :number_of_pages, if: :number_of_pages.to_proc, &:number_of_pages
end

child :organisations => :organisations do
  attribute :name
  node(:url) { |o| organisation_url(o.slug) }
end
