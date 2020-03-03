require "cocoapods"
require "cocoapods_acknowledgements"
require "cocoapods_acknowledgements/addons/files/file_finder"
require "cocoapods_acknowledgements/addons/files/podspec_finder"
require "cocoapods_acknowledgements/addons/modifiers/metadata_plist_modifier"
require "cocoapods_acknowledgements/addons/modifiers/settings_plist_modifier"

module CocoaPodsAcknowledgements
  module AddOns

    Pod::HooksManager.register("cocoapods-acknowledgements-addons", :post_install) do |context, user_options|
      paths = [*user_options[:add]]
      excluded_names = [*user_options[:exclude]]
      includes_spm = user_options[:with_spm] || false

      acknowledgements = paths.reduce([]) do |results, path|
        specs = PodspecFinder.new(Pathname(path).expand_path)
        (results + specs.acknowledgements).uniq { |a| a.spec.name }
      end

      if includes_spm
        Pod::UI.info %(Looking for Swift Package(s))
        spm_acknowledgements = context.umbrella_targets.reduce([]) do |results, target|
          specs = PodspecFinder.new(target.user_project.path, spm = true)
          (results + specs.acknowledgements).uniq { |a| a.spec.name }
        end
        acknowledgements += spm_acknowledgements
        Pod::UI.info %(Found #{spm_acknowledgements.count} Swift Package(s)).green
      end

      sandbox = context.sandbox if defined? context.sandbox
      sandbox ||= Pod::Sandbox.new(context.sandbox_root)

      context.umbrella_targets.each do |target|
        files = FileFinder.new(target, sandbox)

        metadata_plist_modifier = MetadataPlistModifier.new(files.metadata_format_plist)
        metadata_plist_modifier.add(acknowledgements.map(&:metadata_plist_item), excluded_names)

        settings_plist_modifier = SettingsPlistModifier.new(files.markdown, files.settings_format_plists)
        settings_plist_modifier.add(acknowledgements.map(&:settings_plist_item), excluded_names)
      end
    end

  end
end
