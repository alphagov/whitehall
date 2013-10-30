class OrganisationsIndexPresenter < Array
  def executive_offices
    # Organisations are returned in alphabetical order.
    # Inverting it to put the deputy PM's office after the PM's.
    self.class.new((grouped_organisations[:executive_office] || []).reverse)
  end

  def ministerial_departments
    self.class.new(grouped_organisations[:ministerial_department] || [])
  end

  def non_ministerial_departments
    self.class.new(grouped_organisations[:non_ministerial_department] || [])
  end

  def public_corporations
    self.class.new(grouped_organisations[:public_corporation] || [])
  end

  def agencies_and_government_bodies
    self.class.new(grouped_organisations[:agencies_and_government_bodies] || [])
  end

  def devolved_administrations
    self.class.new(grouped_organisations[:devolved_administration] || [])
  end

  def live_count
    @live_count ||= count(&:live?)
  end

  def exempt_count
    @exempt_count ||= count(&:exempt?)
  end

  def potentially_live_count
    length - exempt_count
  end

  private

  def grouped_organisations
    @grouped_organisations ||= group_by { |org|
      if org.type.agency_or_public_body?
        :agencies_and_government_bodies
      else
        org.type.key
      end
    }
  end
end
