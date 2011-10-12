class MinisterialRole < ActiveRecord::Base
  belongs_to :person

  has_many :organisation_ministerial_roles
  has_many :organisations, through: :organisation_ministerial_roles

  has_many :document_ministerial_roles
  has_many :published_policies, through: :document_ministerial_roles, class_name: "Policy", conditions: { state: "published" }, source: :document
  has_many :published_publications, through: :document_ministerial_roles, class_name: "Publication", conditions: { state: "published" }, source: :document

  validates :name, presence: true

  def to_s
    organisation_names = organisations.map(&:name).join(' and ')
    return "#{person.name} (#{name}, #{organisation_names})" if organisations.any? && person
    return "#{name}, #{organisation_names}" if organisations.any?
    return "#{person.name} (#{name})" if person
    return name
  end
end