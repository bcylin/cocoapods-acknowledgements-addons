require "cfpropertylist"
require "cocoapods"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class PlistModifier

      # Initializes a PlistModifier with the info of target and CocoaPods sandbox.
      # @param target [Pod::Installer::PostInstallHooksContext::UmbrellaTargetDescription] the xcodeproj target.
      # @param sandbox [Pod::Sandbox] the CocoaPods sandbox
      def initialize(target, sandbox)
        @plist_path = sandbox.root + "#{target.cocoapods_target_label}-metadata.plist"
      end

      # Adds acknowledgements to the plist except the excluded ones.
      # @param plist_metadata [Array<Hash>] the array of acknowledgement plist metadata.
      # @param excluded_names [Array<String>] the array of names to ignore.
      def add(plist_metadata, excluded_names)
        plist_metadata = [*plist_metadata]
        excluded_names = [*excluded_names]

        return if plist_metadata.empty? or not @plist_path&.writable?

        plist = CFPropertyList::List.new(file: @plist_path)
        entries = plist.value.value["specs"].value
        existing_titles = entries.map { |spec| spec.value["name"].value }
        excluded_names += existing_titles

        additions = plist_metadata.map { |metadata|
          next if excluded_names.include? metadata[:name]
          Pod::UI.info "Adding #{metadata[:name]} to #{@plist_path.basename}"
          CFPropertyList.guess(metadata)
        }.reject(&:nil?)

        acknowledgements = entries + additions
        acknowledgements.sort! { |a, b| a.value["name"].value <=> b.value["name"].value }

        plist.value.value["specs"].value = acknowledgements
        plist.save(@plist_path, CFPropertyList::List::FORMAT_XML)
      end

    end
  end
end
