class CaseStudySerializer < ActiveModel::Serializer
  attributes(
    :description,
    :document_type,
    :public_updated_at,
    :rendering_app,
    :schema_name
  )
  has_one :details, key: :details

  def description
    object.summary
  end

  def details
    CaseStudyDetailsSerializer.new(object).as_json.merge!(
      WithdrawnNoticeSerializer.new(object).as_json
    )
  end

  def document_type
    "case_study"
  end

  def public_updated_at
    object.public_timestamp || object.updated_at
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def schema_name
    "case_study"
  end
end
