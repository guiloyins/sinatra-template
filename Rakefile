require 'rake'
require 'rdoc/task'
require 'rspec/core'
require 'rspec/core/rake_task'
require './config/environment'


# task :default => :spec
Dir["#{Gem::Specification.find_by_name('integration').full_gem_path}/lib/tasks/*.rake"].each { |ext| load ext } if defined?(Rake)
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)

desc "Report code statistics"
task :stats do
  require './vendor/code_statistics'
  
  STATS_DIRECTORIES = [
    %w(Controllers        app/controllers),
    %w(Helpers            app/helpers),
    %w(Models             app/),
    %w(Libraries          lib/),
    %w(Migrations         db/migrations),
    %w(Views              app/views)
  ].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }

  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end