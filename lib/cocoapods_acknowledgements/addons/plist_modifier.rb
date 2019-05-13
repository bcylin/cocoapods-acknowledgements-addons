require "cocoapods"
require "cfpropertylist"

module CocoaPodsAcknowledgements
  module AddOns
    class PlistModifier

      # Adds podspecs to the given plist except the excluded ones.
      # @param podspecs [Array<Hash>] the array of podspec info of acknowledgements.
      # @param plist_path [Pathname] the path to the plist.
      # @param excluded_names [Array<String>] the array of podspec names to ignore.
      def add_podspecs_to_plist(podspecs, plist_path, excluded_names)
        podspecs = [*podspecs]
        excluded_names = [*excluded_names]

        return if podspecs.empty? or not plist_path&.writable?

        plist = CFPropertyList::List.new(file: plist_path)
        acknowledgements = plist.value.value["specs"].value.map { |spec| spec.value["name"].value }

        podspecs.each do |metadata|
          next if excluded_names.include? metadata[:name]
          Pod::UI.info "Adding #{metadata[:name]} to #{plist_path.basename}"

          node = CFPropertyList.guess(metadata)
          next if node.nil? or acknowledgements.include? node.value["name"].value
          plist.value.value["specs"].value.append(node)
        end

        plist.value.value["specs"].value.sort! { |a, b| a.value["name"].value <=> b.value["name"].value }
        plist.save(plist_path, CFPropertyList::List::FORMAT_XML)
      end

    end
  end
end
