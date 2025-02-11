require 'cocoapods'
require_relative '../lib/cocoapods_acknowledgements/addons'
require_relative '../lib/cocoapods_acknowledgements/addons/acknowledgement'
require_relative '../lib/cocoapods_acknowledgements/addons/files/podspec_finder'

describe AddOns = CocoaPodsAcknowledgements::AddOns do
  let(:finder) { instance_double(AddOns::PodspecFinder) }
  let(:spec) { instance_double(Pod::Specification, name: 'LoremIpsum') }
  let(:acknowledgements) { [instance_double(AddOns::Acknowledgement, spec: spec)] }

  let(:project) { instance_double(Xcodeproj::Project, path: 'project.xcodeproj') }
  let(:target) { instance_double(Pod::Installer::BaseInstallHooksContext::UmbrellaTargetDescription, user_project: project) }

  before do
    allow(finder).to receive(:acknowledgements).and_return(acknowledgements)
  end

  it 'finds podspec acknowledgements in the search paths' do
    search_paths = %w[A B].map(&Pathname.method(:new)).map(&:expand_path)
    search_paths.each do |path|
      expect(AddOns::PodspecFinder).to receive(:new).with(search_path: path).and_return(finder)
    end

    results = AddOns.find_podspec_acknowledgements(search_paths)
    expect(results.count).to eq(1)
  end

  it 'finds swift package acknowledgements in the targets' do
    search_targets = [target]
    expect(AddOns::PodspecFinder).to receive(:new).with(xcodeproj_path: 'project.xcodeproj').and_return(finder)

    results = AddOns.find_swift_package_acknowledgements(search_targets)
    expect(results.count).to eq(1)
  end
end
