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

  accepts_nested_attributes_for :fatality_notice_casualties, allow_destroy: true, reject_if: -> attributes { attributes['personal_details'].blank? }

  validates :operational_field, :roll_call_introduction, presence: true

  add_trait CasualtiesTrait

  def can_be_associated_with_worldwide_priorities?
    false
  end

  def has_operational_field?
    true
  end

  def display_type_key
    "fatality_notice"
  end

  def search_format_types
    super + [FatalityNotice.search_format_type]
  end
end
