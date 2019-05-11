require "cocoapods_acknowledgements"
require "cocoapods_acknowledgements/addons/podspec_accumulator"

module CocoaPodsAcknowledgements
  module AddOns

    def self.hello
      Pod::UI.info PodspecAccumulator.new.hello
    end

    Pod::HooksManager.register("cocoapods-acknowledgements-addons", :post_install) do |context, user_options|

      Pod::UI.section "Modifying Acknowledgements" do
        hello
      end
    end

  end
end
