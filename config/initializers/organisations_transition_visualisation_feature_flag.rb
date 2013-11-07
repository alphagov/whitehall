if Rails.env.test? || Rails.env.cucumber?
  Whitehall::organisations_transition_visualisation_feature_enabled = true
else
  Whitehall::organisations_transition_visualisation_feature_enabled = false
end
