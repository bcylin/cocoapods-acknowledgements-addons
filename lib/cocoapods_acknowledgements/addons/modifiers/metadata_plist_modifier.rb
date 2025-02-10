require 'cfpropertylist'
require 'cocoapods'
require 'cocoapods_acknowledgements/addons/acknowledgement'

module CocoaPodsAcknowledgements
  module AddOns
    #
    # A modifier to update cocoapods_acknowledgements generated plist (metadata format), such as:
    # - Pods/Pods-#{app_name}-metadata.plist
    #
    class MetadataPlistModifier
      #
      # @param plist_path [Pathname] the path to the plist file
      #
      def initialize(plist_path)
        @plist_path = plist_path
      end

      #
      # @return [CFPropertyList::List] the acknowledgement plist.
      #
      def plist
        CFPropertyList::List.new(file: @plist_path) if @plist_path&.readable?
      end

      #
      # Adds acknowledgements to the plist except the excluded ones.
      #
      # @param plist_metadata [Array<Hash>] the array of acknowledgement plist metadata.
      # @param excluded_names [Array<String>] the array of names to ignore.
      #
      def add(plist_metadata, excluded_names: nil)
        plist_metadata = [*plist_metadata]
        excluded_names = [*excluded_names].uniq

        return if plist_metadata.empty? or !@plist_path.writable?

        self.class
            .modify_plist(plist, plist_metadata, excluded_names)
            .save(@plist_path, CFPropertyList::List::FORMAT_XML)

        Pod::UI.puts "Saving #{@plist_path}".green
      end

      #
      # @return [CFPropertyList] the updated plist of acknowledgement entries.
      #
      def self.modify_plist(plist, plist_metadata, excluded_names)
        acknowledgements = plist.value.value['specs'].value
        acknowledgements = combine_acknowledgements(acknowledgements, plist_metadata)
        acknowledgements = filter_acknowledgements(acknowledgements, excluded_names)
        plist.value.value['specs'].value = acknowledgements
        plist
      end

      #
      # @return [Array<CFPropertyList::CFDictionary>] the updated array of acknowledgement entries.
      #
      def self.combine_acknowledgements(entries, plist_metadata)
        existing_titles = entries.filter_map { |spec| spec.value['name'].value }
        additions = plist_metadata.filter_map(&to_items_not_match(existing_titles))
        entries + additions
      end

      #
      # @return [Array<CFPropertyList::CFDictionary>] the updated array of acknowledgement entries.
      #
      def self.filter_acknowledgements(entries, excluded_names)
        entries
          .sort(&by_name)
          .reject(&item_matches(excluded_names))
      end

      private_class_method def self.to_items_not_match(existing_titles)
        lambda do |metadata|
          next if existing_titles.include? metadata&.[](:name)

          Pod::UI.info "Adding #{metadata[:name]}"
          CFPropertyList.guess(metadata)
        end
      end

      private_class_method def self.by_name
        ->(a, b) { a.value['name'].value <=> b.value['name'].value }
      end

      private_class_method def self.item_matches(excluded_names)
        lambda do |entry|
          matches = excluded_names.any? do |excluded_name|
            entry.value['name'].value =~ /^#{Regexp.escape(excluded_name).gsub("\*", '.*?')}/
          end

          Pod::UI.info %(Removing #{entry.value['name'].value}) if matches
          matches
        end
      end
    end
  end
end
