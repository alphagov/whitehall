if Rails.env.development?
  namespace :diagrams do
    # Note these all take a comma-separated list of starting Model classes, and produce PlantUML output to stdout
    desc "Generate model associations diagram with extra classes not shown"
    task :model_associations, [:start_models] => :environment do |_, args|
      # note - eager load forces all models to be loaded - don't do this outside dev
      Rails.application.eager_load!
      DiagramGenerator::ModelDiagram.new(args[:start_models].split(","), {through: true, show_associations:true, extra_classes: false}).generate($stdout)
    end
    desc "Generate model association diagram with extra classes shown"
    task :model_associations_plus_extras, [:start_models] => :environment do |_, args|
      # note - eager load forces all models to be loaded - don't do this outside dev
      Rails.application.eager_load!
      DiagramGenerator::ModelDiagram.new(args[:start_models].split(","), {through: true, show_associations:true, extra_classes: true}).generate($stdout)
    end
    desc "Generate model concerns diagram"
    task :model_concerns, [:start_models] => :environment do |_, args|
      # note - eager load forces all models to be loaded - don't do this outside dev
      Rails.application.eager_load!
      DiagramGenerator::ModelDiagram.new(args[:start_models].split(","), {show_concerns:true, extra_classes: true}).generate($stdout)
    end
    desc "Generate model concerns and associations diagram"
    task :model_associations_and_associations, [:start_models] => :environment do |_, args|
      # note - eager load forces all models to be loaded - don't do this outside dev
      Rails.application.eager_load!
      DiagramGenerator::ModelDiagram.new(args[:start_models].split(","), {through: true, show_associations:true, show_concerns: true, extra_classes: true}).generate($stdout)
    end
  end
end