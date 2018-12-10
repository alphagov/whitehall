class LatestController < PublicFacingController
  include CacheControlHelper

  before_action :redirect_unless_subject

  def index; end

private

  helper_method :subject, :documents

  def subject
    case subject_param
    when 'departments'
      Organisation.with_translations(I18n.locale).find(subject_id)
    when 'topical_events'
      TopicalEvent.find(subject_id)
    when 'world_locations'
      WorldLocation.with_translations(I18n.locale).find(subject_id)
    end
  end

  def documents
    filter.documents
  end

  def filter
    @filter = LatestDocumentsFilter.for_subject(subject, page_params)
  end

  def page_params
    { page: filtered_params.fetch(:page, 0) }
  end

  def subject_id
    filtered_params[subject_param].first
  end

  def subject_param
    supported_subjects.find do |param_name|
      filtered_params[param_name].present? && filtered_params[param_name].is_a?(Array)
    end
  end

  def supported_subjects
    %w(departments topical_events world_locations)
  end

  def redirect_unless_subject
    redirect_to atom_feed_path unless subject
  end

  def filtered_params
    params.permit(:page, departments: [], topical_events: [], world_locations: [])
  end
end
