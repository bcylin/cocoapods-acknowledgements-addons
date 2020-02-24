require "cfpropertylist"
require "cocoapods"
require "cocoapods_acknowledgements/addons/acknowledgement"

module CocoaPodsAcknowledgements
  module AddOns
    class SettingsPlistModifier

      # A modifier to update CocoaPods generated markdown and plist (settings.bundle format), such as:
      #
      # - Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.markdown
      # - Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.plist
      # - settings_bundle/#{app_name}-settings-metadata.plist
      #
      # @param markdown_path [Pathname] the path to the markdown file
      # @param plist_paths [Array<Pathname>] the path to the plist files
      #
      def initialize(markdown_path, plist_paths)
        @markdown_path = markdown_path
        @plist_paths = plist_paths
      end

      # @return [String] the acknowledgement texts
      #
      def markdown
        return nil unless @markdown_path&.readable?
        File.read @markdown_path
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
        reference = @plist_paths.first
        plist = plist_with_additional_metadata(reference, plist_metadata, excluded_names)

        @plist_paths.each do |path|
          next unless path&.writable?
          Pod::UI.puts "Saving #{path}".green
          plist.save(path, CFPropertyList::List::FORMAT_XML)
        end

        File.write @markdown_path, markdown_text_with(plist)
      end

      private

      def plist_with_additional_metadata(reference, plist_metadata, excluded_names)
        return nil unless reference&.readable?

        plist = CFPropertyList::List.new(file: reference)
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
          Pod::UI.info "Adding #{metadata[:Title]}"
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
            Pod::UI.info %(Removing #{entry.value["Title"].value}) if matches
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
