class Nation
  include ActiveRecordLikeInterface

  attr_accessor :id, :name

  England = create(id: 1, name: "England")
  Scotland = create(id: 2, name: "Scotland")
  Wales = create(id: 3, name: "Wales")
  NorthernIreland = create(id: 4, name: "Northern Ireland")

  def self.england; England; end
  def self.scotland; Scotland; end
  def self.wales; Wales; end
  def self.northern_ireland; NorthernIreland; end

  def self.potentially_inapplicable
    [Scotland, Wales, NorthernIreland]
  end

  def self.find_by_name!(name)
    nation = all.detect { |n| n.name == name }
    nation || raise("Couldn't find Nation with name = #{name}")
  end
end
