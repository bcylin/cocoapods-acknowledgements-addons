require "cocoapods"
require "cocoapods_acknowledgements"
require "cocoapods_acknowledgements/addons/podspec_accumulator"
require "cocoapods_acknowledgements/addons/plist_modifier"

module CocoaPodsAcknowledgements
  module AddOns

    Pod::HooksManager.register("cocoapods-acknowledgements-addons", :post_install) do |context, user_options|
      paths = [*user_options[:add]]
      excluded_podspecs = [*user_options[:exclude]]

      podspecs = paths.reduce([]) do |specs, path|
        accumulator = PodspecAccumulator.new(Pathname(path).expand_path)
        specs + accumulator.podspecs
      end
      modifier = PlistModifier.new

      sandbox = context.sandbox if defined? context.sandbox
      sandbox ||= Pod::Sandbox.new(context.sandbox_root)

      context.umbrella_targets.each do |target|
        plist_path = sandbox.root + "#{target.cocoapods_target_label}-metadata.plist"
        modifier.add_podspecs_to_plist(podspecs, plist_path, excluded_podspecs)
      end
    end

  end
end
