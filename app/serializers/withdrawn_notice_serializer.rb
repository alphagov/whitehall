class WithdrawnNoticeSerializer < ActiveModel::Serializer
  attribute :withdrawn_notice, if: -> { object.withdrawn? }

  def withdrawn_notice
    WithdrawnNoticeDetailsSerializer.new(object).as_json
  end
end
