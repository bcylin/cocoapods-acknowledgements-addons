module Pod
  class Command
    class Acknowledgements < Command
      class Search < Acknowledgements

        self.arguments = [
          CLAide::Argument.new("PATHS", true)
        ]

        def self.options
          [
            ['--spm', 'Is Swift Package Manager Path']
          ].concat(super)
        end

        def initialize(argv)
          @spm = argv.flag?('spm')
          @arguments = argv.arguments!
          @paths = @arguments.map(&Pathname::method(:new)).map(&:expand_path)
          super
        end

        def validate!
          super
          help! "Path(s) to look for acknowledgements are required" if @paths.empty?
        end

        def run
          if @is_spm
            @paths.each { |path| puts CocoaPodsAcknowledgements::AddOns::PodspecFinder.new(xcodeproj_path: path).files }
          else
            @paths.each { |path| puts CocoaPodsAcknowledgements::AddOns::PodspecFinder.new(search_path: path).files }
          end
        end
      end
    end
  end
end
