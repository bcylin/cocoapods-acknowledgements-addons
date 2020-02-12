desc "Launch the example app"
task :example do
  Rake::Task["install"].execute
  sh "open example/App.xcworkspace"
end

desc "Use the plugin with the example app"
task :install do
  sh "bundle install"
  Dir.chdir("example") { sh "make install-dependencies" }
end

desc "Update dependencies"
task :update do
  sh "bundle update"
  Dir.chdir("example") do
    sh "bundle exec pod install"
  end
end

def xcodebuild(params)
  return ":" unless params[:action]
  [
    %(xcodebuild),
    %(-workspace App.xcworkspace),
    %(-scheme App),
    %(-sdk iphonesimulator),
    %(-destination 'platform=iOS Simulator,name=iPhone 11,OS=latest'),
    params[:action],
    %(| bundle exec xcpretty -c && exit ${PIPESTATUS[0]})
  ].reject(&:nil?).join " "
end

desc "Build the example app"
task :build do
  Dir.chdir("example") do
    sh "make install-dependencies"
    sh xcodebuild(action: "clean build")
    exit $?.exitstatus if not $?.success?
  end
end

desc "Run the tests in the example app"
task :test do
  Dir.chdir("example") do
    sh "make install-dependencies"
    sh xcodebuild(action: "clean test")
    exit $?.exitstatus if not $?.success?
  end
end

task :default => ["install"]
