require "cocoapods"
require "cfpropertylist"

module CocoaPodsAcknowledgements
  module AddOns
    class PlistModifier

      def add_podspecs_to_plist(podspecs = [], plist_path = nil, excluded_podspecs = [])
        return if podspecs.empty? or plist_path.nil?

        plist = CFPropertyList::List.new(file: plist_path)
        acknowledgements = plist.value.value["specs"].value.map { |spec| spec.value["name"].value }

        podspecs.each do |metadata|
          next if (excluded_podspecs || []).include? metadata[:name]
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
