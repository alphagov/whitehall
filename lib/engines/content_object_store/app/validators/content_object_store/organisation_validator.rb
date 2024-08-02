class ContentObjectStore::OrganisationValidator < ActiveModel::Validator
  attr_reader :edition

  def validate(edition)
    @edition = edition
    if edition.edition_organisation.blank?
      edition.errors.add("lead_organisation", :blank, message: "cannot be blank")
    end
  end
end
