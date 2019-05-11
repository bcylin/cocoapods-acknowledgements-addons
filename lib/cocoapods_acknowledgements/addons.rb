require "cocoapods_acknowledgements"
require "cocoapods_acknowledgements/addons/podspec_accumulator"

module CocoaPodsAcknowledgements
  module AddOns

    Pod::HooksManager.register("cocoapods-acknowledgements-addons", :post_install) do |context, user_options|

      path = user_options[:add] || ""
      accumulator = PodspecAccumulator.new(Pathname(path).expand_path)

      accumulator.podspecs.each do |podspec|
        Pod::UI.info "Adding #{podspec[:name]} to Acknowledgements"
      end
    end

  end
end
