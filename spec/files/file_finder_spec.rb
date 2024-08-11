require 'cocoapods'
require_relative '../../lib/cocoapods_acknowledgements/addons/acknowledgement'
require_relative '../../lib/cocoapods_acknowledgements/addons/files/file_finder'

describe FileFinder = CocoaPodsAcknowledgements::AddOns::FileFinder do
  let(:target) { instance_double(Pod::Installer::BaseInstallHooksContext::UmbrellaTargetDescription) }
  let(:sandbox) { instance_double(Pod::Sandbox) }
  let(:xcodeproj) { instance_double(Xcodeproj::Project) }

  let(:settings_bundle) { instance_double(Xcodeproj::Project::Object::PBXFileReference, path: 'Settings.bundle') }
  let(:settings_bundle_path) { Pathname.new('./LoremIpsum/Settings.bundle') }

  before do
    allow(target).to receive(:cocoapods_target_label).and_return('Pods-LoremIpsum')
    allow(target).to receive(:user_project_path).and_return(Pathname.new('./LoremIpsum.xcodeproj'))

    allow(sandbox).to receive(:root).and_return(Pathname.new('./Pods/'))
    allow(sandbox).to receive(:target_support_files_root).and_return(Pathname.new('./Pods/Target Support Files/'))

    allow(Xcodeproj::Project).to receive(:open).and_return(xcodeproj)
  end

  context 'when initialized' do
    before do
      allow(FileFinder).to receive(:find_settings_plist).and_return(nil)
      @file_finder = FileFinder.new(target, sandbox)
    end

    it 'finds the the file paths' do
      expect(@file_finder.metadata_format_plist.to_s).to eq('./Pods/Pods-LoremIpsum-metadata.plist')
      expect(@file_finder.markdown.to_s).to eq('./Pods/Target Support Files/Pods-LoremIpsum/Pods-LoremIpsum-acknowledgements.markdown')
      expect(@file_finder.settings_format_plists).to eq(
        [
          Pathname.new('./Pods/Target Support Files/Pods-LoremIpsum/Pods-LoremIpsum-acknowledgements.plist'),
          nil
        ]
      )
    end
  end

  context 'when finding plist' do
    context 'with settings bundle' do
      before do
        allow(xcodeproj).to receive(:files).and_return([settings_bundle])
        allow(settings_bundle).to receive(:real_path).and_return(settings_bundle_path)
        allow(settings_bundle_path).to receive(:exist?).and_return(true)
      end

      it 'returns the settings metadata plist' do
        expect(FileFinder.find_settings_plist(target).to_s).to eq('./LoremIpsum/Settings.bundle/Pods-LoremIpsum-settings-metadata.plist')
      end
    end

    context 'without settings bundle' do
      before do
        allow(xcodeproj).to receive(:files).and_return([])
      end

      it 'returns nil' do
        expect(FileFinder.find_settings_plist(target)).to be_nil
      end
    end
  end
end
