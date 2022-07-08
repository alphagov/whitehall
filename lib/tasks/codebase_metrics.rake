require "tmpdir"

class Options
  attr_accessor :repo_dir, :repo_url, :last_build_url, :revision

  def initialize(params = {})
    @repo_dir = params[:repo_dir] || ENV["REPO_DIR"]
    @repo_url = params[:repo_url] || ENV["REPO_URL"] || "https://github.com/alphagov/whitehall.git"
    @revision = params[:revision] || ENV["REVISION"] || "main"
    @last_build_url = params[:last_build_url] || ENV["LAST_BUILD_URL"] || "https://ci.integration.publishing.service.gov.uk/job/whitehall/job/#{@revision}/lastSuccessfulBuild/console"
  end
end

class CodebaseMetrics
  attr_accessor :options, :current_commit_sha,
                :total_size, :number_of_items,
                :models, :views, :controllers, :presenters,
                :routes

  def initialize(opts)
    @options = opts
  end

  def prepare!
    checkout_clean_repo(options)
  end

  def gather
    @total_size = get_total_size
    @number_of_items = get_number_of_files_under(".")
    @models = get_number_of_files_under("./app/models")
    @views = get_number_of_files_under("./app/views")
    @controllers = get_number_of_files_under("./app/controllers")
    @presenters = get_number_of_files_under("./app/presenters")
    @routes = (@options.revision == "main" ? get_number_of_routes : "N/A unless on main")
  end

  def report
    puts <<~METRICS

      Codebase metrics #{@options.revision == 'main' ? "as of #{Time.zone.now.iso8601}, current" : 'for'} revision #{@current_commit_sha}
      -----------------------------------------------------------------------------------------------------------

      Total size:                 #{@total_size} bytes
      Total size (MB):            #{(@total_size / (1024.0 * 1024.0)).round(2)}MB
      Number of items in Github:  #{@number_of_items}
      Number of models:           #{@models}
      Number of views:            #{@views}
      Number of controllers:      #{@controllers}
      Number of presenters:       #{@presenters}
      Number of routes:           #{@routes}
    METRICS

    if @options.revision == "main"
      puts <<~HOWTO

        You can retrieve "Test coverage %" and "Time to build (s)" from the latest
        build against "main" in Jenkins, at:
          #{options.last_build_url}
      HOWTO
    else
      puts <<~HOWTO

        To get "Number of routes", run this line in a Rails console against this revision:
          Rails.application.routes.routes.map { |r| {path: r.path.spec.to_s}}.uniq.count

          (Note, this gets less and less likely to work for older revisions, due to
          gem version locks & deprecations, etc)


        To get "Test coverage %" and "Time to build (s)", run:
          git checkout #{@current_commit_sha}
          git push -u origin (some unique branch name)

        You can then retrieve those figures from the console output of that build in Jenkins, at:
          #{options.last_build_url.gsub('/main/', '/(your branch name)/')}
      HOWTO
    end
    puts <<~DEVRATING

      Developer rating is an average score from 1 to 10 to the question:
      "Overall, how difficult is it to make changes to Whitehall publisher?"
      where 1 = terrible, 10 = very easy
      It"s best asked of @publishing-experience-devs on Slack.


    DEVRATING
  end

protected

  def get_total_size
    `du --apparent-size -sb .`.strip.to_i
  end

  def get_number_of_items
    `find . -type f | wc -l`.strip.to_i
  end

  def get_number_of_files_under(dir = ".")
    `find #{dir} | wc -l`.strip.to_i
  end

  def get_number_of_routes
    `bundle install --quiet`
    `bundle exec rails runner "puts Rails.application.routes.routes.map { |r| {path: r.path.spec.to_s}}.uniq.count" `.split("\n").last.strip
  rescue StandardError
    puts "Could not calculate the number of routes in revision #{@revision}"
    puts "This may be due to some gems from that versions' Gemfile.lock no longer being available"
  end

  def checkout_clean_repo(opts)
    `git clone --quiet #{opts.repo_url}`
    Dir.chdir("./whitehall") do
      `git checkout --quiet #{opts.revision}`
      # store this so we can echo it back when we report
      @current_commit_sha = `git rev-parse HEAD`.strip
      `rm -rf ./.git `
    end
  end
end

namespace :codebase do
  desc "run the monthly 'make whitehall simpler' metrics against a clean repo under /tmp/"
  task metrics: :environment do
    opts = Options.new
    metrics = CodebaseMetrics.new(opts)

    Dir.mktmpdir("report-codebase-metrics", opts.repo_dir) do |tmp_dir|
      Dir.chdir(tmp_dir) do
        metrics.prepare!
        Dir.chdir("./whitehall") do
          metrics.gather
        end
        metrics.report
      end
    end
  end
end
