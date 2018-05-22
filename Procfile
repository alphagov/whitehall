web: bundle exec unicorn -c ./config/unicorn.rb -p ${PORT:-3020}
worker: bundle exec sidekiq -C ./config/sidekiq_publishing.yml
worker: bundle exec sidekiq -C ./config/sidekiq.yml
