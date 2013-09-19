module Edition::CanBeExternal
  extend ActiveSupport::Concern

  included do
    validates :external_url, presence: { if: :external? }
    validates :external_url, uri: true, allow_blank: true
  end
end
