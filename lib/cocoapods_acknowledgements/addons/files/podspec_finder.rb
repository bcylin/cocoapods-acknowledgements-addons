require "cocoapods-core"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class PodspecFinder
      attr_reader :files

      # @param search_path [Pathname] the directory to look for podspecs.
      #
      def initialize(params = { search_path: nil, xcodeproj_path: nil })
        @files =
          if params[:xcodeproj_path]
            build_dir = %x{xcodebuild -project "#{params[:xcodeproj_path]}" -showBuildSettings | grep -m 1 BUILD_DIR | grep -oEi "\/.*"}.strip
            source_packages_dir = Pathname(build_dir) + "../../SourcePackages/checkouts"
            Dir[source_packages_dir + "*/*.podspec"] # skip nested git submodules
          elsif params[:search_path]
            Dir[Pathname(params[:search_path]).expand_path + "**/*.podspec"]
          else
            []
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
