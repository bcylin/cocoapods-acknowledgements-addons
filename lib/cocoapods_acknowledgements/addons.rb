require "cocoapods"
require "cocoapods_acknowledgements"
require "cocoapods_acknowledgements/addons/podspec_accumulator"
require "cocoapods_acknowledgements/addons/plist_modifier"
require "cocoapods_acknowledgements/addons/settings_plist_modifier"

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
        plist_modifier = PlistModifier.new(target, sandbox)
        plist_modifier.add(acknowledgements.map(&:plist_metadata), excluded_names)

        settings_plist_modifier = SettingsPlistModifier.new(target)
        settings_plist_modifier.add(acknowledgements.map(&:settings_plist_metadata), excluded_names)
      end
    end

  end
end
