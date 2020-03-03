require "cocoapods-core"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class PodspecFinder
      attr_reader :files

      # @param search_path [Pathname] the directory to look for podspecs.
      #
      def initialize(search_path = Pathname("").expand_path, spm = false)
        @files =
          if spm
            build_dir = %x{xcodebuild -project "#{search_path}" -showBuildSettings | grep -m 1 BUILD_DIR | grep -oEi "\/.*"}.strip
            source_packages_dir = Pathname(build_dir) + "../../SourcePackages/checkouts"
            Dir[source_packages_dir + "*/*.podspec"] # skip nested git submodules
          else
            Dir[search_path + "**/*.podspec"]
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
