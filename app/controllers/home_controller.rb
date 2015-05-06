class HomeController < PublicFacingController
  layout 'frontend'

  enable_request_formats feed: [:atom]

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document).limit(10)
  end

  def how_government_works
    # Brief hack to automatically change parts of the how-gov-works page once
    # a new government has formed (at any point after polling day)
    # @TODO: Remove once new government in place and this page is updated properly
    @is_new_gov = new_gov?

    sitewide_setting = load_reshuffle_setting
    @is_during_reshuffle = sitewide_setting.on if sitewide_setting
    @policy_count = Policy.published.count
    sorter = MinisterSorter.new
    @cabinet_minister_count = sorter.cabinet_ministers.count - 1 # subtract one to discount PM
    @other_minister_count = sorter.other_ministers.count
    @all_ministers_count = @cabinet_minister_count + @other_minister_count + 1 # add one to put the PM back in
    @ministerial_department_count = Organisation.listable.ministerial_departments.count
    @non_ministerial_department_count = Organisation.listable.non_ministerial_departments.count
  end

  def get_involved
    @open_consultation_count = Consultation.published.open.count
    @closed_consultation_count = Consultation.published.closed_since(1.year.ago).count
    @next_closing_consultations = decorate_collection(Consultation.published.open.order("closing_at asc").limit(1), PublicationesquePresenter)
    @recently_opened_consultations = decorate_collection(Consultation.published.open.order("opening_at desc").limit(3), PublicationesquePresenter)
    @recent_consultation_outcomes = decorate_collection(Consultation.published.closed.responded.order("closing_at desc").limit(3), PublicationesquePresenter)
    @take_part_pages = TakePartPage.in_order
  end

  def history_king_charles_street
  end

  def history_lancaster_house
  end

private

  def new_gov?
    current_gov = Government.current
    polling_day = Date.new(2015, 05, 07)
    current_gov && current_gov.start_date >= polling_day
  end
end
