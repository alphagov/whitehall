extends "documents/show"
object @document

attributes :opening_on, :closing_on
attributes :open? => :open

child :nation_inapplicabilities => :nation_inapplicabilities do
  attribute :name
  node :alternative_url, if: lambda { |o| o.alternative_url.present? }, &:alternative_url
end

child :published_consultation_response do
  object @document.response
  attributes :summary

  child :attachments => :attachments do
    attributes :title, :content_type, :file_size, :url
    node :number_of_pages, if: :number_of_pages.to_proc, &:number_of_pages
  end
end
