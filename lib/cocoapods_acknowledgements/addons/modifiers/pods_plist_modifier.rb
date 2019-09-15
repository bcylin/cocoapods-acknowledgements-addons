require "cfpropertylist"
require "cocoapods"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class PodsPlistModifier

      # A modifier to update:
      #
      # - Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.{plist|markdown}
      # - settings_bundle/#{app_name}-settings-metadata.plist"
      #
      # @param target [Pod::Installer::PostInstallHooksContext::UmbrellaTargetDescription] the xcodeproj target.
      # @param sandbox [Pod::Sandbox] the CocoaPods sandbox
      #
      def initialize(target, sandbox)
        @markdown_path = sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.markdown"
        @plist_path = sandbox.target_support_files_root + target.cocoapods_target_label + "#{target.cocoapods_target_label}-acknowledgements.plist"

        project = Xcodeproj::Project.open(target.user_project_path)
        file = project.files.find { |f| f.path =~ /Settings\.bundle$/ }
        settings_bundle = file&.real_path
        @settings_plist = settings_bundle + "#{target.cocoapods_target_label}-settings-metadata.plist" if settings_bundle&.exist?
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

      # @return [CFPropertyList::List] the acknowledgement plist in the app Settings.bundle.
      #
      def settings_plist
        return nil unless @settings_plist&.readable?
        CFPropertyList::List.new(file: @settings_plist)
      end

      # Adds acknowledgements to the CocoaPods generated plist and markdown files except the excluded ones.
      #
      # @param plist_metadata [Array<Hash>] the array of acknowledgement plist metadata.
      # @param excluded_names [Array<String>] the array of names to ignore.
      #
      def add(plist_metadata, excluded_names)
        plist_metadata = [*plist_metadata]
        excluded_names = [*excluded_names]

        return if plist_metadata.empty?
        plist = plist_with_additional_metadata(plist_metadata, excluded_names)

        [@plist_path, @settings_plist].each do |path|
          next unless path&.writable?
          Pod::UI.puts "Saving #{path}".green
          plist.save(path, CFPropertyList::List::FORMAT_XML)
        end

        File.write @markdown_path, markdown_text_with(plist)
      end

      private

      def plist_with_additional_metadata(plist_metadata, excluded_names)
        return nil unless @plist_path&.readable?

        plist = CFPropertyList::List.new(file: @plist_path)
        entries = plist.value.value["PreferenceSpecifiers"].value

        header = entries.first
        footer = entries.last
        attributes = [header.value["Title"].value, footer.value["Title"].value]

        existing_titles = entries
          .map { |spec| spec.value["Title"].value }
          .reject { |title| attributes.include? title }
        excluded_names.uniq!

        additions = plist_metadata.map do |metadata|
          next if metadata.nil? or existing_titles.include? metadata[:Title]
          Pod::UI.info "Adding #{metadata[:Title]} to #{@plist_path.basename}"
          CFPropertyList.guess(metadata)
        end.reject(&:nil?)

        acknowledgements = entries[1...-1] + additions
        acknowledgements
          .sort! { |a, b| a.value["Title"].value <=> b.value["Title"].value }
          .reject! do |entry|
            matches = excluded_names.any? do |excluded_name|
              pattern = %r(^#{Regexp.escape(excluded_name).gsub("\*", ".*?")})
              entry.value["Title"].value =~ pattern
            end
            Pod::UI.info %(Removing #{entry.value["Title"].value} from #{@plist_path.basename}) if matches
            matches
          end

        footer.value["FooterText"].value.gsub!("http:", "https:")

        plist.value.value["PreferenceSpecifiers"].value = [header] + acknowledgements + [footer]
        plist
      end

      def markdown_text_with(plist)
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
      end
    end
  end
end
