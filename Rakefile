desc "Bump versions"
task :bump, [:version] do |t, args|
  version = args[:version]
  unless version
    puts %{Usage: rake "bump[version]"}
    next
  end

  Dir.chdir("example") { sh "xcrun agvtool new-marketing-version #{version}" }

  spec = "lib/version.rb"
  text = File.read spec
  File.write spec, text.gsub(%r(\"\d+\.\d+\.\d+\"), "\"#{version}\"")
  puts "Updated #{spec} to #{version}"

  changelog = "CHANGELOG.md"
  text = File.read changelog
  File.write changelog, text.gsub(%r(Next release), "#{version}")
  puts "Updated #{changelog} to #{version}"

  Rake::Task["install"].execute
end

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
