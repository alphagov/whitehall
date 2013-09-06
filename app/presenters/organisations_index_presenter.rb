class OrganisationsIndexPresenter
  def initialize(organisations)
    @organisations = organisations
  end

  def all
    @organisations
  end

  def executive_offices
    # Organisations are returned in alphabetical order.
    # Inverting it to put the deputy PM's office after the PM's.
    grouped_organisations[:executive_office].present? ? grouped_organisations[:executive_office].reverse : [] 
  end

  def ministerial_departments
    grouped_organisations[:ministerial_department] || []
  end

  def non_ministerial_departments
    grouped_organisations[:non_ministerial_department] || []
  end

  def public_corporations
    grouped_organisations[:public_corporation] || []
  end

  def agencies_and_government_bodies
    grouped_organisations[:agencies_and_government_bodies] || []
  end  

  private

  def grouped_organisations
    @grouped_organisations ||= @organisations.group_by { |org|
      if [:executive_office, :ministerial_department, :non_ministerial_department, :public_corporation].include?(org.organisation_type_key)
        org.organisation_type_key
      else
        :agencies_and_government_bodies
      end
    }
  end
end