class FatalityNotice < Announcement
  include Edition::RoleAppointments
  include Edition::FactCheckable

  belongs_to :operational_field

  class CasualtiesTrait < Edition::Traits::Trait
    def process_associations_after_save(new_edition)
      @edition.fatality_notice_casualties.each do |casualty|
        new_edition.fatality_notice_casualties.create(casualty.attributes.except(:id))
      end
    end
  end

  has_many :fatality_notice_casualties, dependent: :destroy

  accepts_nested_attributes_for :fatality_notice_casualties, allow_destroy: true, reject_if: :all_blank

  validates :operational_field, :roll_call_introduction, presence: true

  add_trait CasualtiesTrait

  def has_operational_field?
    true
  end
end
