require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = 'test/**/*_test.rb'
  t.warning = false
end

task default: :test
