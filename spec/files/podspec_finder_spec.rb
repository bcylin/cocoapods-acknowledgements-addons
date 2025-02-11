require 'cocoapods'
require_relative '../../lib/cocoapods_acknowledgements/addons/acknowledgement'
require_relative '../../lib/cocoapods_acknowledgements/addons/files/podspec_finder'

describe PodspecFinder = CocoaPodsAcknowledgements::AddOns::PodspecFinder do
  context 'when initialized with xcodeproj path' do
    before do
      allow(PodspecFinder)
        .to receive(:swift_packages_dir).with('LoremIpsum.xcodeproj')
        .and_return('SourcePackages/checkouts/')
      allow(Dir).to receive(:[])
        .with('SourcePackages/checkouts/*/*.podspec')
        .and_return(['SourcePackages/checkouts/LibraryA/LibraryA.podspec'])
    end

    it 'finds the podspecs in the swift packages directory' do
      podspec_finder = PodspecFinder.new(xcodeproj_path: 'LoremIpsum.xcodeproj')
      expect(podspec_finder.files).to eq(['SourcePackages/checkouts/LibraryA/LibraryA.podspec'])
    end
  end

  context 'when initialized with search path' do
    before do
      allow(Dir).to receive(:[])
        .with(Pathname('path/to/search').expand_path + '**/*.podspec')
        .and_return(['path/to/search/LibraryB/LibraryB.podspec'])
    end

    it 'finds the podspecs in the serch path' do
      expect(PodspecFinder).not_to receive(:swift_packages_dir)

      podspec_finder = PodspecFinder.new(search_path: 'path/to/search')
      expect(podspec_finder.files).to eq(['path/to/search/LibraryB/LibraryB.podspec'])
    end
  end

  context 'when initialized with empty params' do
    it 'returns an empty array' do
      expect(PodspecFinder).not_to receive(:swift_packages_dir)

      podspec_finder = PodspecFinder.new
      expect(podspec_finder.files).to eq([])
    end
  end

  context 'swift packages directory' do
    before do
      allow(PodspecFinder).to receive(:`)
        .and_return('~/Library/Developer/Xcode/DerivedData/LoremIpsum-dolorsitamet/Build/Products')
    end

    it 'returns the path to source package checkouts' do
      expect(Xcodeproj::Project).to receive(:schemes).with('LoremIpsum.xcodeproj')
      expect(PodspecFinder.swift_packages_dir('LoremIpsum.xcodeproj').to_s)
        .to eq('~/Library/Developer/Xcode/DerivedData/LoremIpsum-dolorsitamet/SourcePackages/checkouts')
    end
  end
end
