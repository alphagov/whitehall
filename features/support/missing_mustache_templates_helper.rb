# features tagged @javascript require mustache templates to be compiled,
# or else a javascript error for undefined variable: templates occurs

Before('@javascript') do
  # to prevent this callback from executing before each scenario
  $mustache_templates_looked_up ||= false

  unless $mustache_templates_looked_up
    $mustache_templates_looked_up = true

    if File.zero?(Rails.root + "app/assets/javascripts/templates.js")
      puts "ERROR: Scenarios tagged @javascript require mustache templates to be compiled first." +
        " Execute 'rake shared_mustache:compile' before running these scenarios."

      exit 1
    end
  end
end
