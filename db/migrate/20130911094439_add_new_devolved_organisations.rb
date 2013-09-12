class AddNewDevolvedOrganisations < ActiveRecord::Migration
  def devolved_administrations
    [
      ['Scottish Parliament', 'http://www.scottish.parliament.uk/'],
      ['National Assembly for Wales','http://www.assemblywales.org/'],
      ['Northern Ireland Assembly','http://www.niassembly.gov.uk/'],
    ]
  end

  def up
    devolved_administrations.each do |administration|
      name, url = administration
      Organisation.create!( name: name,
                            logo_formatted_name: name,
                            organisation_type: OrganisationType.devolved_administration,
                            url: url,
                            organisation_logo_type_id: OrganisationLogoType::NoIdentity.id,
                            govuk_status: 'exempt')
    end
  end

  def down
    devolved_administrations.each do |administration|
      name = administration[0]
      Organisation.find_by_name(name).destroy
    end
  end
end
