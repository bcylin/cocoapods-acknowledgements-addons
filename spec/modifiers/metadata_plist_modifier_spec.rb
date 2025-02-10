require 'cocoapods'
require 'cfpropertylist'
require_relative '../helpers/mapping'
require_relative '../../lib/cocoapods_acknowledgements/addons/acknowledgement'
require_relative '../../lib/cocoapods_acknowledgements/addons/modifiers/metadata_plist_modifier'

describe MetadataPlistModifier = CocoaPodsAcknowledgements::AddOns::MetadataPlistModifier do
  let(:plist_path) { Pathname.new(File.join(File.dirname(__FILE__), '../fixtures/metadata-format.plist')) }
  let(:plist) { CFPropertyList::List.new(file: plist_path) }
  let(:modifier) { MetadataPlistModifier.new(plist_path) }

  before(:all) do
    CFPropertyList::CFDictionary.include(Mapping)
  end

  context 'when initialized' do
    it 'finds the plist' do
      modifier = MetadataPlistModifier.new(plist_path)
      expect(modifier.plist).to be_a(CFPropertyList::List)
    end

    it 'has no plist when the path is not readable' do
      allow(plist_path).to receive(:readable?).and_return(false)

      expect(modifier.plist).to be_nil
    end
  end

  context 'when modifying' do
    before do
      allow(modifier).to receive(:plist).and_return(plist)
      allow(plist).to receive(:save)
    end

    it 'does nothing when the data is empty' do
      expect(Pod::UI).not_to receive(:puts)
      expect(plist).not_to receive(:value)
      expect(plist).not_to receive(:save)

      modifier.add([])
    end

    it 'does nothing when the plist is not writable' do
      allow(plist_path).to receive(:writable?).and_return(false)

      expect(Pod::UI).not_to receive(:puts)
      expect(plist).not_to receive(:value)
      expect(plist).not_to receive(:save)

      modifier.add([{ name: 'LibraryA' }])
    end

    it 'adds acknowledgements to the plist' do
      plist_metadata = %w[LibraryC LibraryD].map { |name| { name: name } }

      expect(MetadataPlistModifier).to receive(:modify_plist).with(plist, plist_metadata, []).and_return(plist)
      expect(plist).to receive(:save).with(plist_path, CFPropertyList::List::FORMAT_XML)
      expect(Pod::UI).to receive(:puts).with("Saving #{plist_path}".green)

      modifier.add(plist_metadata, excluded_names: nil)
    end

    it 'removes the excluded names' do
      plist_metadata = %w[LibraryC LibraryD].map { |name| { name: name } }

      expect(MetadataPlistModifier).to receive(:modify_plist).with(plist, plist_metadata, ['LibraryA']).and_return(plist)
      expect(plist).to receive(:save).with(plist_path, CFPropertyList::List::FORMAT_XML)
      expect(Pod::UI).to receive(:puts).with("Saving #{plist_path}".green)

      modifier.add(plist_metadata, excluded_names: ['LibraryA'])
    end

    it 'adds additional entries and removes duplicates' do
      acknowledgements = %w[LibraryA LibraryB].map { |name| CFPropertyList.guess(name: name) }
      plist_metadata = %w[LibraryB LibraryC].map { |name| { name: name } }

      expect(Pod::UI).to receive(:info).with('Adding LibraryC')
      results = MetadataPlistModifier.combine_acknowledgements(acknowledgements, plist_metadata)

      expect(results.map(&:to_names)).to eq(%w[LibraryA LibraryB LibraryC])
    end

    it 'filters out excluded names and reorders the list' do
      acknowledgements = %w[LibraryC LibraryA LibraryB].map { |name| CFPropertyList.guess(name: name) }
      excluded_names = ['LibraryB']

      expect(Pod::UI).to receive(:info).with('Removing LibraryB')
      results = MetadataPlistModifier.filter_acknowledgements(acknowledgements, excluded_names)

      expect(results.map(&:to_names)).to eq(%w[LibraryA LibraryC])
    end
  end
end
