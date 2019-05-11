require "cocoapods"
require "cocoapods_acknowledgements"
require "cocoapods_acknowledgements/addons/podspec_accumulator"
require "cocoapods_acknowledgements/addons/plist_modifier"

module CocoaPodsAcknowledgements
  module AddOns

    Pod::HooksManager.register("cocoapods-acknowledgements-addons", :post_install) do |context, user_options|

      path = user_options[:add] || ""
      accumulator = PodspecAccumulator.new(Pathname(path).expand_path)
      modifier = PlistModifier.new

      sandbox = context.sandbox if defined? context.sandbox
      sandbox ||= Pod::Sandbox.new(context.sandbox_root)

      context.umbrella_targets.each do |target|
        plist_path = sandbox.root + "#{target.cocoapods_target_label}-metadata.plist"
        modifier.add_podspecs_to_plist(accumulator.podspecs, plist_path)
      end
    end

  end
end
