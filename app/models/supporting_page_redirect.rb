class SupportingPageRedirect < ActiveRecord::Base
  belongs_to :policy_document, class_name: "Document"
  belongs_to :supporting_page_document, class_name: "Document"

  def destination
    Whitehall.url_maker.policy_supporting_page_path(policy_document,
                                                    supporting_page_document)
  end
end
