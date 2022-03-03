Whitehall::Application.config.to_prepare do
  ActionView::Base.default_form_builder = Whitehall::FormBuilder
end
