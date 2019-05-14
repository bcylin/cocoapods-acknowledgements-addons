desc "Launch the example app"
task :example do
  Rake::Task["run:install"].execute
  sh "open example/App.xcworkspace"
end

namespace :run do
  desc "Test the plugin with the example app"
  task :install do
    Dir.chdir("example") { sh "make install" }
  end

  desc "Run the tests in the example app"
  task :tests do
    Dir.chdir("example") do
      sh [
        %(xcodebuild),
        %(-workspace App.xcworkspace),
        %(-scheme App),
        %(-sdk iphonesimulator),
        %(-destination 'platform=iOS Simulator,name=iPhone X,OS=12.1'),
        %(clean test),
        %(| bundle exec xcpretty -c)
      ].join " "
    end
  end
end

task :default => ["run:install"]
