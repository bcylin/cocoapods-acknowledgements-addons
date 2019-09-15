desc "Launch the example app"
task :example do
  Rake::Task["install"].execute
  sh "open example/App.xcworkspace"
end

desc "Use the plugin with the example app"
task :install do
  Dir.chdir("example") { sh "make install" }
end

desc "Run the tests in the example app"
task :test do
  Dir.chdir("example") do
    sh [
      %(xcodebuild),
      %(-workspace App.xcworkspace),
      %(-scheme App),
      %(-sdk iphonesimulator),
      %(-destination 'platform=iOS Simulator,name=iPhone X,OS=12.1'),
      %(clean test),
      %(| bundle exec xcpretty -c && exit ${PIPESTATUS[0]})
    ].join " "
    exit $?.exitstatus if not $?.success?
  end
end

task :default => ["install"]
