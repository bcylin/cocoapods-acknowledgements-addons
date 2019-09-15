require "cocoapods"
require "cocoapods_acknowledgements"
require "cocoapods_acknowledgements/addons/podspec_accumulator"
require "cocoapods_acknowledgements/addons/modifiers/pods_plist_modifier"
require "cocoapods_acknowledgements/addons/modifiers/metadata_plist_modifier"
require "cocoapods_acknowledgements/addons/modifiers/settings_plist_modifier"

module CocoaPodsAcknowledgements
  module AddOns

    Pod::HooksManager.register("cocoapods-acknowledgements-addons", :post_install) do |context, user_options|
      paths = [*user_options[:add]]
      excluded_names = [*user_options[:exclude]]

      acknowledgements = paths.reduce([]) do |results, path|
        accumulator = PodspecAccumulator.new(Pathname(path).expand_path)
        results + accumulator.acknowledgements
      end

      sandbox = context.sandbox if defined? context.sandbox
      sandbox ||= Pod::Sandbox.new(context.sandbox_root)

      context.umbrella_targets.each do |target|
        metadata_plist_modifier = MetadataPlistModifier.new(target, sandbox)
        metadata_plist_modifier.add(acknowledgements.map(&:metadata_plist_item), excluded_names)

        settings_plist_modifier = SettingsPlistModifier.new(target)
        settings_plist_modifier.add(acknowledgements.map(&:settings_plist_item), excluded_names)

        plist = settings_plist_modifier.plist
        pods_plist_modifier = PodsPlistModifier.new(target, sandbox)
        pods_plist_modifier.update_files_with(plist)
      end
    end

  end
end
