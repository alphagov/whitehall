class ContactType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  def self.find_by_name(name)
    all.detect { |type| type.name == name }
  end

  General = create(
    id: 1, name: "General contact",
  )
  FOI = create(
    id: 2, name: "Freedom of Information contact",
  )
  Media = create(
    id: 3, name: 'Media contact',
  )
end
