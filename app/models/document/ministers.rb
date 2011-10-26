module Document::Ministers
  extend ActiveSupport::Concern

  included do
    has_many :document_ministerial_roles, foreign_key: :document_id
    has_many :ministerial_roles, through: :document_ministerial_roles
  end
  
  def can_be_associated_with_ministers?
    true
  end

  module ClassMethods
    def in_ministerial_role(role)
      joins(:ministerial_roles).where('roles.id' => role)
    end
  end
end