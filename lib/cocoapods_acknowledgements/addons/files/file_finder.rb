require "cocoapods-core"

module CocoaPodsAcknowledgements
  module AddOns
    class FileFinder
      attr_reader :metadata_format_plist, :markdown

      # An object to find the file paths:
      #
      # - metadata_format_plist: Pods/Pods-#{app_name}-metadata.plist
      # - markdown: Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.markdown
      # - settings_format: {
      #     pods_plist: Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.plist,
      #     bundle_plist: Settings.bundle/#{app_name}-settings-metadata.plist"
      #   }
      #
      # @param target [Pod::Installer::PostInstallHooksContext::UmbrellaTargetDescription] the xcodeproj target
      # @param sandbox [Pod::Sandbox] the CocoaPods sandbox
      #
      def initialize(target, sandbox)
        @metadata_format_plist = sandbox.root + "#{target.cocoapods_target_label}-metadata.plist"
        @markdown = sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.markdown"

        find_settings_plist = Proc.new do
          project = Xcodeproj::Project.open(target.user_project_path)
          file = project.files.find { |f| f.path =~ /Settings\.bundle$/ }
          settings_bundle = file&.real_path
          next unless settings_bundle&.exist?
          settings_bundle + "#{target.cocoapods_target_label}-settings-metadata.plist"
        end

        @settings_format = {
          pods_plist: sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.plist",
          bundle_plist: find_settings_plist.call
        }
      end

      # @return [Array<Pathname>] the path to the Settings.bundle format plist files
      #
      def settings_format_plists
        [@settings_format[:pods_plist], @settings_format[:bundle_plist]]
      end

    end
  end
end
