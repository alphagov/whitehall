class HomeController < PublicFacingController
  layout 'frontend'

  def home
    ministerial_department_type = OrganisationType.find_by_name('Ministerial department')
    sub_organisation_type = OrganisationType.find_by_name('Sub-organisation')
    @live_ministerial_departments = Organisation.where("organisation_type_id = ? AND govuk_status ='live'", ministerial_department_type)
    @live_other_departments = Organisation.where("organisation_type_id NOT IN (?,?) AND govuk_status='live'", ministerial_department_type, sub_organisation_type)
    @transitioning_ministerial_departments = Organisation.where("organisation_type_id = ? AND govuk_status ='transitioning'", ministerial_department_type)
    @transitioning_other_departments = Organisation.where("organisation_type_id NOT IN (?, ?) AND govuk_status='transitioning'", ministerial_department_type, sub_organisation_type)
    @classifications = Classification.order(:name).where("(type = 'Topic' and published_policies_count <> 0) or (type = 'TopicalEvent')").alphabetical
  end

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document, :organisations).limit(10)
  end

  def sunset
    render layout: 'home'
  end

  def how_government_works
    @policy_count = Policy.published.count
    @non_ministerial_department_count = Organisation.where(organisation_type_id: OrganisationType.find_by_name('Non-ministerial department')).count
    sorter = MinisterSorter.new
    @cabinet_minister_count = sorter.cabinet_ministers.count - 1 # subtract one to discount PM
    @other_minister_count = sorter.other_ministers.count
    @all_ministers_count = @cabinet_minister_count + @other_minister_count + 1 # add one to put the PM back in
  end

  def get_involved
    @open_consultation_count = Consultation.published.open.count
    @closed_consultation_count = Consultation.published.closed_since(1.year.ago).count
    @next_closing_consultation = PublicationesquePresenter.decorate(Consultation.published.open.order("closing_on asc").limit(1).first)
    @recently_opened_consultations = PublicationesquePresenter.decorate(Consultation.published.open.order("opening_on desc").limit(3))
    @recent_consultation_outcomes = PublicationesquePresenter.decorate(Consultation.published.responded.order("closing_on desc").limit(3))
  end

  def history_king_charles_street
  end

  def history_lancaster_house
  end

end
