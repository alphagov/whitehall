unless Rails.env.production?
  namespace :diagrams do
    desc "Generate model diagram with extra classes not shown"
    task :model, [:start_models] => :environment do |_, args|
      puts "Generating model diagram for #{args[:start_models]}"
      # note - eager load forces all models to be loaded for us
      Rails.application.eager_load!
      DiagramGenerator::ModelDiagram.new(args[:start_models].split(","), {through: true, extra_classes: false}).generate($stdout)
    end
  end
end