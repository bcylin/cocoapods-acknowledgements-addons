desc "Launch the example app"
task :example do
  Rake::Task["dev:install"].execute
  sh "open example/App.xcworkspace"
end

namespace :dev do
  desc "Test the plugin with the example app"
  task :install do
    Dir.chdir("example") { sh "make install" }
  end
end

task :default => ["dev:install"]
