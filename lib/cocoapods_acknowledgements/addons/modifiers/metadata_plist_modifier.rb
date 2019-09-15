require "cfpropertylist"
require "cocoapods"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class MetadataPlistModifier

      # A modifier to update Pods/Pods-#{app_name}-metadata.plist.
      #
      # @param target [Pod::Installer::PostInstallHooksContext::UmbrellaTargetDescription] the xcodeproj target.
      # @param sandbox [Pod::Sandbox] the CocoaPods sandbox
      #
      def initialize(target, sandbox)
        @plist_path = sandbox.root + "#{target.cocoapods_target_label}-metadata.plist"
      end

      # @return [CFPropertyList::List] the acknowledgement plist at Pods/Pods-#{app_name}-metadata.plist.
      #
      def plist
        return nil unless @plist_path&.readable?
        CFPropertyList::List.new(file: @plist_path)
      end

      # Adds acknowledgements to the plist except the excluded ones.
      #
      # @param plist_metadata [Array<Hash>] the array of acknowledgement plist metadata.
      # @param excluded_names [Array<String>] the array of names to ignore.
      #
      def add(plist_metadata, excluded_names)
        plist_metadata = [*plist_metadata]
        excluded_names = [*excluded_names]

        return if plist_metadata.empty? or not @plist_path&.writable?

        plist = CFPropertyList::List.new(file: @plist_path)
        entries = plist.value.value["specs"].value
        existing_titles = entries.map { |spec| spec.value["name"].value }
        excluded_names.uniq!

        additions = plist_metadata.map do |metadata|
          next if metadata.nil? or existing_titles.include? metadata[:name]
          Pod::UI.info "Adding #{metadata[:name]} to #{@plist_path.basename}"
          CFPropertyList.guess(metadata)
        end.reject(&:nil?)

        acknowledgements = entries + additions
        acknowledgements
          .sort! { |a, b| a.value["name"].value <=> b.value["name"].value }
          .reject! do |entry|
            matches = excluded_names.any? do |excluded_name|
              pattern = %r(^#{Regexp.escape(excluded_name).gsub("\*", ".*?")})
              entry.value["name"].value =~ pattern
            end
            Pod::UI.info %(Removing #{entry.value["name"].value} from #{@plist_path.basename}) if matches
            matches
          end

        plist.value.value["specs"].value = acknowledgements
        plist.save(@plist_path, CFPropertyList::List::FORMAT_XML)

        Pod::UI.puts "Saving #{@plist_path}".green
      end

    end
  end
end
