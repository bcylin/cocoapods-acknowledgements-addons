require "cfpropertylist"
require "cocoapods"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class PodsPlistModifier

      # @param target [Pod::Installer::PostInstallHooksContext::UmbrellaTargetDescription] the xcodeproj target.
      # @param sandbox [Pod::Sandbox] the CocoaPods sandbox
      #
      def initialize(target, sandbox)
        @markdown_path = sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.markdown"
        @plist_path = sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.plist"
      end

      # @return [String] the acknowledgement texts at Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.markdown.
      #
      def markdown
        return nil unless @markdown_path&.readable?
        File.read @markdown_path
      end

      # @return [CFPropertyList::List] the acknowledgement plist at Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.plist.
      #
      def plist
        return nil unless @plist_path&.readable?
        CFPropertyList::List.new(file: @plist_path)
      end

      # @param plist [CFPropertyList::List] the acknowledgement plist to update the target files.
      #
      def update_files_with(plist)
        entries = plist.value.value["PreferenceSpecifiers"].value
        header = entries.first
        footer = entries.last
        acknowledgements = entries[1...-1].map do |entry|
          <<~ACKNOWLEDGEMENT.strip
            ## #{entry.value["Title"].value}

            #{entry.value["FooterText"].value}
          ACKNOWLEDGEMENT
        end

        texts = <<~MARKDOWN
          # #{header.value["Title"].value}
          #{header.value["FooterText"].value}

          #{acknowledgements.join("\n\n\n")}

          #{footer.value["FooterText"].value}
        MARKDOWN

        # Update markdown
        File.write @markdown_path, texts

        # Update plist
        plist.save(@plist_path, CFPropertyList::List::FORMAT_XML)
      end
    end
  end
end
