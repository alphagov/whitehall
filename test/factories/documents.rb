FactoryGirl.define do
  factory :document do
    author
    title "document-title"
    body "document-body"
  end

  factory :draft_document, parent: :document do
    state "draft"
  end

  factory :submitted_document, parent: :draft_document do
    state "submitted"
  end

  factory :rejected_document, parent: :document do
    state "rejected"
  end

  factory :published_document, parent: :document do
    state "published"
  end

  factory :deleted_document, parent: :document do
    state "deleted"
  end

  factory :archived_document, parent: :document do
    state "archived"
  end
end