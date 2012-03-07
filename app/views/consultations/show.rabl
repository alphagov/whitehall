extends "documents/show"
object @document

attributes :opening_on, :closing_on
attributes :open? => :open

child :nation_inapplicabilities => :nation_inapplicabilities do
  attribute :name
  node :alternative_url, if: lambda { |o| o.alternative_url.present? }, &:alternative_url
end

child :published_consultation_response,
  if: :published_consultation_response.to_proc do
  object @document.published_consultation_response
  extends "documents/show"
end
