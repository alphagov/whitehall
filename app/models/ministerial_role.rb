class MinisterialRole < ActiveRecord::Base
  has_many :organisation_ministerial_roles
  has_many :organisations, through: :organisation_ministerial_roles
  belongs_to :person

  validates :name, presence: true

  def to_s
    organisation_names = organisations.map(&:name).join(' and ')
    return "#{person.name} (#{name}, #{organisation_names})" if organisations.any? && person
    return "#{name}, #{organisation_names}" if organisations.any?
    return "#{person.name} (#{name})" if person
    return name
  end
end