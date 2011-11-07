FactoryGirl.define do
  factory :publication do
    author
    title "publication-title"
    body  "publication-body"
  end

  factory :published_publication, parent: :publication do
    state "published"
  end

  factory :draft_publication, parent: :publication do
    state "draft"
  end

  factory :archived_publication, parent: :publication do
    state "archived"
  end

  factory :submitted_publication, parent: :publication do
    state "submitted"
  end

  factory :rejected_publication, parent: :publication do
    state "rejected"
  end
end