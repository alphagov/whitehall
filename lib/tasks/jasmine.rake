desc "Run Jasmine tests"
task jasmine: :environment do
  sh "yarn run jasmine:ci"
end
