class FatalityNoticePresenter < Struct.new(:model, :context)
  include EditionPresenterHelper

  fatality_notice_methods = FatalityNotice.instance_methods - Object.instance_methods
  delegate *fatality_notice_methods, to: :model

end
