class HomeController < PublicFacingController
  layout 'frontend'

  enable_request_formats feed: [:atom]

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document).limit(10)
  end

  def how_government_works
    sitewide_setting = load_reshuffle_setting
    @is_during_reshuffle = sitewide_setting.on if sitewide_setting
    @prime_minister = MinisterialRole.find_by(slug: 'prime-minister').current_person
    sorter = MinisterSorter.new
    @cabinet_minister_count = sorter.cabinet_ministers.count - 1 # subtract one to discount PM
    @other_minister_count = sorter.other_ministers.count
    @all_ministers_count = @cabinet_minister_count + @other_minister_count + 1 # add one to put the PM back in
    @ministerial_department_count = Organisation.listable.ministerial_departments.count
    @non_ministerial_department_count = Organisation.listable.non_ministerial_departments.count
  end

  def get_involved
    @open_consultation_count = Consultation.published.open.count
    @closed_consultation_count = Consultation.published.closed_at_or_after(1.year.ago).count
    @next_closing_consultations = decorate_collection(Consultation.published.open.order("closing_at asc").limit(1), PublicationesquePresenter)
    @recently_opened_consultations = decorate_collection(Consultation.published.open.order("opening_at desc").limit(3), PublicationesquePresenter)
    @recent_consultation_outcomes = decorate_collection(Consultation.published.closed.responded.order("closing_at desc").limit(3), PublicationesquePresenter)
    @take_part_pages = TakePartPage.in_order
  end

  def history_king_charles_street; end

  def history_lancaster_house; end
end
