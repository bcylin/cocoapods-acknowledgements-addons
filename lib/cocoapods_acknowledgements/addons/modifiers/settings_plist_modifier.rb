require 'cfpropertylist'
require 'cocoapods'
require 'cocoapods_acknowledgements/addons/acknowledgement'

module CocoaPodsAcknowledgements
  module AddOns
    #
    # A modifier to update CocoaPods generated markdown and plist (settings.bundle format), such as:
    #
    # - Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.markdown
    # - Pods/Target Support Files/Pods-#{app_name}/Pods-#{app_name}-acknowledgements.plist
    # - settings_bundle/#{app_name}-settings-metadata.plist
    #
    # rubocop:disable Metrics/AbcSize
    class SettingsPlistModifier
      #
      # @param markdown_path [Pathname] the path to the markdown file
      # @param plist_paths [Hash<Symbol, Pathname>] the path to the plist files
      #
      def initialize(markdown_path, plist_paths)
        @markdown_path = markdown_path
        @pods_plist_path = plist_paths[:pods_plist]
        @bundle_plist_path = plist_paths[:bundle_plist]
        @plist_paths = plist_paths.values.compact.filter(&:writable?)
      end

      #
      # @return [String] the acknowledgement texts
      #
      def markdown
        File.read @markdown_path if @markdown_path&.readable?
      end

      #
      # @return [CFPropertyList::List] the acknowledgement plist.
      #
      def pods_plist
        CFPropertyList::List.new(file: @pods_plist_path) if @pods_plist_path&.readable?
      end

      #
      # @return [CFPropertyList::List] the acknowledgement plist.
      #
      def bundle_plist
        CFPropertyList::List.new(file: @bundle_plist_path) if @bundle_plist_path&.readable?
      end

      #
      # Adds acknowledgements to the CocoaPods generated plist and markdown files except the excluded ones.
      #
      # @param plist_metadata [Array<Hash>] the array of acknowledgement plist metadata.
      # @param excluded_names [Array<String>] the array of names to ignore.
      #
      def add(plist_metadata, excluded_names: nil)
        plist_metadata = [*plist_metadata]
        excluded_names = [*excluded_names].uniq

        return if plist_metadata.empty?

        plist = self.class.modify_plist(pods_plist, plist_metadata, excluded_names)

        @plist_paths.each do |path|
          Pod::UI.puts "Saving #{path}".green
          plist.save(path, CFPropertyList::List::FORMAT_XML)
        end

        File.write @markdown_path, self.class.markdown_text_with(plist) if @markdown_path&.writable?
      end

      #
      # @return [CFPropertyList] an updated plist of acknowledgement entries.
      #
      def self.modify_plist(plist, plist_metadata, excluded_names)
        entries = plist.value.value['PreferenceSpecifiers'].value

        header = entries.first
        acknowledgements = combine_acknowledgements(entries[1...-1], plist_metadata)
        acknowledgements = filter_acknowledgements(acknowledgements, excluded_names)
        footer = entries.last
        footer.value['FooterText'].value.gsub!('http:', 'https:')

        plist.value.value['PreferenceSpecifiers'].value = [header] + acknowledgements + [footer]
        plist
      end

      #
      # @return [Array<CFPropertyList::CFDictionary>] the updated array of acknowledgement entries.
      #
      def self.combine_acknowledgements(entries, plist_metadata)
        existing_titles = entries.filter_map { |spec| spec.value['Title'].value }
        additions = plist_metadata.filter_map(&to_items_not_match(existing_titles))
        entries + additions
      end

      def self.filter_acknowledgements(entries, excluded_names)
        entries
          .sort(&by_name)
          .reject(&item_matches(excluded_names))
      end

      #
      # @return [String] the updated acknowledgement markdown text.
      #
      def self.markdown_text_with(plist)
        entries = plist.value.value['PreferenceSpecifiers'].value
        header = entries.first
        footer = entries.last

        acknowledgements = entries[1...-1].map do |entry|
          <<~ACKNOWLEDGEMENT.strip
            ## #{entry.value['Title'].value}

            #{entry.value['FooterText'].value}
          ACKNOWLEDGEMENT
        end

        <<~MARKDOWN
          # #{header.value['Title'].value}
          #{header.value['FooterText'].value}

          #{acknowledgements.join("\n\n\n")}

          #{footer.value['FooterText'].value}
        MARKDOWN
      end

      private_class_method def self.to_items_not_match(existing_titles)
        lambda do |metadata|
          next if existing_titles.include? metadata&.[](:Title)

          Pod::UI.info "Adding #{metadata[:Title]}"
          CFPropertyList.guess(metadata)
        end
      end

      private_class_method def self.by_name
        ->(a, b) { a.value['Title'].value <=> b.value['Title'].value }
      end

      private_class_method def self.item_matches(excluded_names)
        lambda do |entry|
          matches = excluded_names.any? do |excluded_name|
            pattern = /^#{Regexp.escape(excluded_name).gsub("\*", '.*?')}/
            entry.value['Title'].value =~ pattern
          end

          Pod::UI.info %(Removing #{entry.value['Title'].value}) if matches
          matches
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
