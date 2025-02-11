module Pod
  class Command
    class Acknowledgements < Command
      class Search < Acknowledgements
        self.arguments = [
          CLAide::Argument.new('PATHS', true)
        ]

        def self.options
          [
            ['--swift-packages', 'Search for the Swift package dependencies of an Xcode project']
          ].concat(super)
        end

        def initialize(argv)
          @is_swift_package = argv.flag?("swift\-packages")
          @arguments = argv.arguments!
          @paths = @arguments.map(&Pathname.method(:new)).map(&:expand_path)
          super
        end

        def validate!
          super
          help! 'It requires the PATHS to look for acknowledgements' if @paths.empty?
        end

        def run
          if @is_swift_package
            @paths.each { |path| puts CocoaPodsAcknowledgements::AddOns::PodspecFinder.new(xcodeproj_path: path).files }
          else
            @paths.each { |path| puts CocoaPodsAcknowledgements::AddOns::PodspecFinder.new(search_path: path).files }
          end
        end
      end
    end
  end
end
