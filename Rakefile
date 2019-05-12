desc "Launch the example app"
task :example do
  Rake::Task["dev:install"].execute
  sh "open Example/App.xcworkspace"
end

namespace :dev do
  desc "Test the plugin with the example app"
  task :install do
    Dir.chdir("Example") do
      sh "git submodule update --init --recursive"
      sh "carthage bootstrap --platform ios --no-build"
      sh "bundle install"
      sh "bundle exec pod install"
    end
  end
end

task :default => ["dev:install"]
