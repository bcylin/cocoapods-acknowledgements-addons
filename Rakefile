task default: [:install]

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

desc "Publish package"
task :publish do
  require "version.rb"
  version = CocoaPodsAcknowledgements::AddOns::VERSION
  package = "cocoapods-acknowledgements-addons-#{version}.gem"
  sh "gem build cocoapods_acknowledgements_addons.gemspec"
  sh "gem push #{package}"
  sh "gem push --key github --host https://rubygems.pkg.github.com/bcylin #{package}"
end
