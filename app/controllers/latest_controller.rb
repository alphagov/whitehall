class LatestController < PublicFacingController
  include CacheControlHelper

  before_filter :redirect_unless_subject

  def index
  end

  def subject
    case subject_param
    when 'departments'
      Organisation.with_translations(I18n.locale).find(subject_id)
    when 'topics'
      Classification.find(subject_id)
    when 'world_locations'
      WorldLocation.with_translations(I18n.locale).find(subject_id)
    end
  end
  helper_method :subject

  def documents
    Whitehall::Decorators::CollectionDecorator.new(filter.documents,
                                                   LatestDocumentPresenter,
                                                   view_context)
  end
  helper_method :documents

private
  def filter
    @filter = LatestDocumentsFilter.for_subject(subject, page_params)
  end

  def page_params
    {page: params.fetch(:page, 0)}
  end

  def subject_id
    params[subject_param].first
  end

  def subject_param
    supported_subjects.find do |param_name|
      params[param_name].present?
    end
  end

  def supported_subjects
    %w(departments topics world_locations)
  end

  def redirect_unless_subject
    redirect_to atom_feed_path unless subject
  end
end
