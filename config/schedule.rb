every 10.minutes, roles: [:backend] do
  rake "publishing:due:publish"
end
