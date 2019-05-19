require "cfpropertylist"
require "cocoapods"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class SettingsPlistModifier

      # Initializes a SettingsPlistModifier with the info of target.
      # @param target [Pod::Installer::PostInstallHooksContext::UmbrellaTargetDescription] the xcodeproj target.
      # @return [SettingsPlistModifier] a settings plist modifier or nil when Settings.bundle doesn't exist.
      def initialize(target)
        project = Xcodeproj::Project.open(target.user_project_path)
        file = project.files.find { |f| f.path =~ /Settings\.bundle$/ }
        settings_bundle = file&.real_path

        return nil unless settings_bundle&.exist?
        @plist_path = settings_bundle + "#{target.cocoapods_target_label}-settings-metadata.plist"
      end

      # Adds acknowledgements to the plist except the excluded ones.
      # @param plist_metadata [Array<Hash>] the array of acknowledgement plist metadata.
      # @param excluded_names [Array<String>] the array of names to ignore.
      def add(plist_metadata, excluded_names)
        plist_metadata = [*plist_metadata]
        excluded_names = [*excluded_names]

        return if plist_metadata.empty? or not @plist_path&.writable?

        plist = CFPropertyList::List.new(file: @plist_path)
        entries = plist.value.value["PreferenceSpecifiers"].value

        header = entries.first
        footer = entries.last
        attributes = [header.value["Title"].value, footer.value["Title"].value]

        existing_titles = entries
          .map { |spec| spec.value["Title"].value }
          .reject { |title| attributes.include? title }
        excluded_names += existing_titles

        additions = plist_metadata.map { |metadata|
          next if excluded_names.include? metadata[:Title]
          Pod::UI.info "Adding #{metadata[:Title]} to #{@plist_path.basename}"
          CFPropertyList.guess(metadata)
        }.reject(&:nil?)

        acknowledgements = entries[1...-1] + additions
        acknowledgements.sort! { |a, b| a.value["Title"].value <=> b.value["Title"].value }

        plist.value.value["PreferenceSpecifiers"].value = [header] + acknowledgements + [footer]
        plist.save(@plist_path, CFPropertyList::List::FORMAT_XML)
      end

    end
  end
end
