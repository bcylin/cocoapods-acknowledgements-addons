require "cocoapods-core"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class SwiftPackageAccumulator

      # @param xcodeproj_path [Pathname] the directory to look for podspecs.
      #
      def initialize(xcodeproj_path = nil)
        if xcodeproj_path.nil?
          @files = []
        else
          build_dir = %x{xcodebuild -project #{xcodeproj_path} -showBuildSettings | grep -m 1 BUILD_DIR | grep -oEi "\/.*"}.strip
          source_packages_dir = Pathname(build_dir) + "../../SourcePackages/checkouts"
          @files = Dir[source_packages_dir + "*/*.podspec"] # skip nested git submodules
        end
      end

      # @return [Array<Acknowledgement>] the array of Acknowledgement objects.
      #
      def acknowledgements
        @files.map { |file| Acknowledgement.new(file) }
      end

    end
  end
end
