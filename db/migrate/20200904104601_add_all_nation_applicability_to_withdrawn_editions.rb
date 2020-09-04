class AddAllNationApplicabilityToWithdrawnEditions < ActiveRecord::Migration[5.1]
  def up
    Edition.where(type: %w[DetailedGuide Publication Consultation], state: "withdrawn").each do |edition|
      if edition.nation_inapplicabilities.any?
        edition.update_column(:all_nation_applicability, false)
      end
    end
  end

  def down; end
end
