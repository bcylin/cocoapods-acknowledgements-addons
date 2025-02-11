require 'cocoapods-core'
require 'cocoapods_acknowledgements/addons/acknowledgement'

module CocoaPodsAcknowledgements
  module AddOns
    class PodspecFinder
      attr_reader :files

      #
      # @param search_path [Hash<Symbol, String>] the directory to look for podspecs.
      #
      def initialize(params = { search_path: nil, xcodeproj_path: nil })
        @files =
          if params[:xcodeproj_path]
            source_packages_dir = self.class.swift_packages_dir(params[:xcodeproj_path])
            Dir[source_packages_dir + '*/*.podspec'] # skip nested git submodules
          elsif params[:search_path]
            Dir[Pathname(params[:search_path]).expand_path + '**/*.podspec']
          else
            []
          end
      end

      #
      # @return [Array<Acknowledgement>] the array of Acknowledgement objects.
      #
      def acknowledgements
        @files.map { |file| Acknowledgement.new(file) }
      end

      #
      # @param search_path [String] the path to the Xcode project to look for Swift Packages.
      #
      # @return [Pathname] the directory that contains the Swift Package dependencies.
      #
      def self.swift_packages_dir(xcodeproj_path)
        scheme = Xcodeproj::Project.schemes(xcodeproj_path)&.first
        build_dir = `xcodebuild -project "#{xcodeproj_path}" -showBuildSettings -scheme #{scheme} 2>/dev/null | grep -m 1 BUILD_DIR | grep -oEi "\/.*"`.strip
        Pathname(build_dir) + '../../SourcePackages/checkouts'
      end
    end
  end
end
