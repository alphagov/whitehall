class PromotionalSectionLayout
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :columns, :title

  TwoColumn           = create(id: 1, name: 'Two column', columns: 2, title: false)
  ThreeColumn         = create(id: 2, name: 'Three column', columns: 3, title: false)
  ThreeColumnGrouped  = create(id: 3, name: 'Three column grouped', columns: 3, title: true)
end
