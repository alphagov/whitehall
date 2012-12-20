class TopicalEvent < Classification
  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  has_many :announcments, through: :classification_memberships
  has_many :news_articles, through: :classification_memberships
  has_many :speeches, through: :classification_memberships

  has_many :published_announcements,
            through: :classification_memberships,
            class_name: "Announcement",
            conditions: { "editions.state" => "published" },
            source: :announcement

  has_many :published_publications,
            through: :classification_memberships,
            class_name: "Publication",
            conditions: { "editions.state" => "published" },
            source: :publication

  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true

end