namespace :dev do
  desc "Test the plugin with the example app"
  task :test do
    Dir.chdir("Example") do
      sh "carthage bootstrap --platform ios --no-build"
      sh "bundle install"
      sh "bundle exec pod install"
    end
  end
end

task :default => ["dev:test"]
