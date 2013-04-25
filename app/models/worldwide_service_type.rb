require 'active_record_like_interface'

class WorldwideServiceType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  def slug
    name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.find_by_slug(slug)
    all.detect { |pt| pt.slug == slug }
  end

  AssistanceServices  = create(id: 1, name: 'Assistance Services')
  DocumentaryServices = create(id: 2, name: 'Documentary Services')

  OtherServices       = create(id: 99, name: 'Other Services')
end
