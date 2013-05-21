class SpeechPresenter < Whitehall::Decorators::Decorator
  include EditionPresenterHelper

  delegate_instance_methods_of Speech

  def delivered_on
    date_microformat(:delivered_on)
  end
end
