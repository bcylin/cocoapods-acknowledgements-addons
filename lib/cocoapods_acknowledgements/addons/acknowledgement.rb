require "cocoapods-core"

module CocoaPodsAcknowledgements
  module AddOns
    class Acknowledgement

      # Initializes an object that contains the Acknowledgement data.
      # @param path [String] the path string to a pod spec.
      def initialize(file)
        return nil unless file and Pathname(file).expand_path.exist?

        @spec = Pod::Specification.from_file(file)

        license_file = @spec.license[:file] || "LICENSE"
        @license_path = File.join(File.dirname(file), license_file)
      end

      def license_text
        File.read(@license_path)
      end

      # @return [Hash] the acknowledgement info for the plist.
      def plist_metadata
        {
          name: @spec.name,
          version: @spec.version.to_s,
          authors: Hash[@spec.authors.map { |k, v| [k, v || ""] }],
          socialMediaURL: @spec.social_media_url || "",
          summary: @spec.summary,
          licenseType: @spec.license[:type],
          licenseText: license_text,
          homepage: @spec.homepage
        }
      end

      def settings_plist_metadata
        {
          Title: @spec.name,
          Type: "PSGroupSpecifier",
          FooterText: license_text
        }
      end

    end
  end
end
