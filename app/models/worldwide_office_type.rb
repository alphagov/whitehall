# encoding: utf-8

class WorldwideOfficeType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :grouping, :listing_order

  def slug
    name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.find_by_name(name)
    all.detect { |type| type.name == name }
  end

  def self.find_by_slug(slug)
    all.detect { |type| type.slug == slug }
  end

  def self.in_listing_order
    all.sort_by(&:listing_order)
  end

  def self.by_grouping
    in_listing_order.group_by(&:grouping)
  end

  # FCO office types
  Embassy                     = create(id:  1, name: 'Embassy', grouping: 'FCO', listing_order: 0)
  Consulate                   = create(id:  2, name: 'Consulate', grouping: 'FCO', listing_order: 1)
  HighCommission              = create(id:  3, name: 'High Commission', grouping: 'FCO', listing_order: 2)
  DeputyHighCommission        = create(id:  4, name: 'Deputy High Commission', grouping: 'FCO', listing_order: 3)
  Delegation                  = create(id:  5, name: 'Delegation', grouping: 'FCO', listing_order: 4)
  PermanentRepresentation     = create(id:  6, name: 'Permanent Representation', grouping: 'FCO', listing_order: 5)
  Mission                     = create(id:  7, name: 'Mission', grouping: 'FCO', listing_order: 6)
  JointDelegation             = create(id:  8, name: 'Joint Delegation', grouping: 'FCO', listing_order: 7)
  PermanentDelegation         = create(id:  9, name: 'Permanent Delegation', grouping: 'FCO', listing_order:  8)
  HMGovernorsOffice           = create(id: 10, name: 'HM Governor’s Office', grouping: 'FCO', listing_order:  9)
  BritishTradeACulturalOffice = create(id: 11, name: 'British Trade and Cultural Office', grouping: 'FCO', listing_order: 10)
  BritishInterestsSection     = create(id: 12, name: 'British Interests Section', grouping: 'FCO', listing_order: 11)
  HonoraryConsul              = create(id: 13, name: 'Honorary Consul', grouping: 'FCO', listing_order: 12)

  # Other office types
  Other                       = create(id: 999, name: 'Other', grouping: 'Other', listing_order: 99)
end
