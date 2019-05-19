require "cocoapods-core"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class PodspecAccumulator

      # Initializes a PodspecAccumulator with a search path.
      # @param search_path [Pathname] the directory to look for podspecs.
      def initialize(search_path = Pathname("").expand_path)
        @files = Dir[search_path + "**/*.podspec"]
      end

      # @return [Array<Acknowledgement>] the array of Acknowledgement objects.
      def acknowledgements
        @files.map { |file| Acknowledgement.new(file) }
      end

    end
  end
end
