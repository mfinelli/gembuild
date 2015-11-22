require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
end
YARD::Rake::YardocTask.new(:yard)

# Checking the spec files on travis causes an error and the build to fail.
# task default: [:rubocop, :spec]
task default: :spec
