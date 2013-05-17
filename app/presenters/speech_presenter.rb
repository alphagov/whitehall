class SpeechPresenter < Struct.new(:model, :context)
  include EditionPresenterHelper

  speech_methods = Speech.instance_methods - Object.instance_methods
  delegate *speech_methods, to: :model

  def delivered_on
    date_microformat(:delivered_on)
  end
end
