FactoryGirl.define do
  factory :publication, class: Publication, parent: :document do
    title "publication-title"
    body  "publication-body"
  end

  factory :draft_publication, parent: :publication, traits: [:draft]
  factory :submitted_publication, parent: :publication, traits: [:submitted]
  factory :rejected_publication, parent: :publication, traits: [:rejected]
  factory :published_publication, parent: :publication, traits: [:published]
  factory :deleted_publication, parent: :publication, traits: [:deleted]
  factory :archived_publication, parent: :publication, traits: [:archived]
end