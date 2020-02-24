require "cocoapods-core"

module CocoaPodsAcknowledgements
  module AddOns
    class FileFinder
      attr_reader :metadata_format_plist, :markdown

      # An object to find the file paths:
      #
      # - metadata_format_plist: Pods/Pods-#{app_name}-metadata.plist
      # - markdown: Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.markdown
      # - pods_format: {
      #     plist: Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.plist,
      #     settings_plist: settings_bundle/#{app_name}-settings-metadata.plist"
      #   }
      #
      # @param target [Pod::Installer::PostInstallHooksContext::UmbrellaTargetDescription] the xcodeproj target.
      # @param sandbox [Pod::Sandbox] the CocoaPods sandbox
      #
      def initialize(target, sandbox)
        @metadata_format_plist = sandbox.root + "#{target.cocoapods_target_label}-metadata.plist"
        @markdown = sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.markdown"

        find_settings_plist = Proc.new do
          project = Xcodeproj::Project.open(target.user_project_path)
          file = project.files.find { |f| f.path =~ /Settings\.bundle$/ }
          settings_bundle = file&.real_path
          return nil unless settings_bundle&.exist?
          settings_bundle + "#{target.cocoapods_target_label}-settings-metadata.plist"
        end

        @pods_format = {
          plist: sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.plist",
          settings_plist: find_settings_plist.call
        }
      end

      # @return [Array<Pathname>] the path to the Pods format plist files
      #
      def pods_format_plists
        [@pods_format[:plist], @pods_format[:settings_plist]]
      end

    end
  end
end
