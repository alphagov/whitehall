class PublicationesquePresenter < Draper::Base
  include EditionPresenterHelper
  include ConsultationsHelper

  decorates :publicationesque

  def display_date_attribute_name
    case publicationesque
    when Publication
      :publication_date
    when Consultation
      :timestamp_for_sorting
    when StatisticalDataSet
      :first_published_at
    else
      raise "Unexpected type: #{publicationesque.type}"
    end
  end

  def display_publication_type
    case publicationesque
    when Publication
      publication_type.singular_name
    when Consultation
      consultation_header_title(self)
    when StatisticalDataSet
      "Statistical data set"
    else
      raise "Unexpected type: #{publicationesque.type}"
    end
  end
end
