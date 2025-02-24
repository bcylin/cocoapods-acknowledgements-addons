require 'cocoapods'
require 'cocoapods_acknowledgements'
require 'cocoapods_acknowledgements/addons/files/file_finder'
require 'cocoapods_acknowledgements/addons/files/podspec_finder'
require 'cocoapods_acknowledgements/addons/modifiers/metadata_plist_modifier'
require 'cocoapods_acknowledgements/addons/modifiers/settings_plist_modifier'

module CocoaPodsAcknowledgements
  module AddOns
    Pod::HooksManager.register('cocoapods-acknowledgements-addons', :post_install) do |context, user_options|
      paths = [*user_options[:add]].map(&Pathname.method(:new)).map(&:expand_path)
      excluded_names = [*user_options[:exclude]]
      include_swift_packages = user_options.fetch(:include_swift_packages) { user_options.fetch(:with_spm, false) }

      acknowledgements = AddOns.find_podspec_acknowledgements(paths)
      acknowledgements += AddOns.find_swift_package_acknowledgements(context.umbrella_targets) if include_swift_packages

      sandbox = context.sandbox if defined? context.sandbox
      sandbox ||= Pod::Sandbox.new(context.sandbox_root)

      context.umbrella_targets.each do |target|
        files = FileFinder.new(target, sandbox)

        metadata_plist_modifier = MetadataPlistModifier.new(files.metadata_format_plist)
        metadata_plist_modifier.add(acknowledgements.map(&:metadata_plist_item), excluded_names: excluded_names)

        settings_plist_modifier = SettingsPlistModifier.new(files.markdown, files.settings_format)
        settings_plist_modifier.add(acknowledgements.map(&:settings_plist_item), excluded_names: excluded_names)
      end
    end

    #
    # @param search_paths [Array<Pathname>] the directories to look for podspecs.
    #
    # @return [Array<Acknowledgement>] the array of Acknowledgement objects.
    #
    def self.find_podspec_acknowledgements(search_paths)
      search_paths.reduce([]) do |results, path|
        finder = PodspecFinder.new(search_path: Pathname(path).expand_path)
        (results + finder.acknowledgements).uniq { |a| a.spec.name }
      end
    end

    #
    # @param targets [Array<Pod::Installer::BaseInstallHooksContext::UmbrellaTargetDescription>] the targets to look for swift package dependencies.
    #
    # @return [Array<Acknowledgement>] the array of Acknowledgement objects.
    #
    def self.find_swift_package_acknowledgements(targets)
      targets.reduce([]) do |results, target|
        finder = PodspecFinder.new(xcodeproj_path: target.user_project.path)
        (results + finder.acknowledgements).uniq { |a| a.spec.name }
      end
    end
  end
end
