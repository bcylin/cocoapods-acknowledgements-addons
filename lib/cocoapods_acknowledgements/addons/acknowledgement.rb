require "cocoapods-core"

module CocoaPodsAcknowledgements
  module AddOns
    class Acknowledgement

      # @param path [String] the path string to a pod spec.
      #
      def initialize(file)
        path = Pathname(file).expand_path if file
        directory = path.dirname

        @spec = Pod::Specification.from_file(file) if path.exist?
        @license_text = license_text(@spec, directory)
      end

      # @param podspec [Pod::Specification]
      # @param directory [Pathname]
      #
      # @return [String] the text of the license.
      # @return [Nil] if it's not found.
      #
      def license_text(podspec, directory)
        return nil unless podspec
        text = podspec.license[:text]

        if text.nil?
          license_file = podspec.license[:file] || "LICENSE"
          license_path = directory + license_file
          return nil unless license_path.exist?
          text = File.read(license_path)
        end

        text
      end

      # @return [Hash] the acknowledgement info for the Pods metadata plist.
      # @return [Nil] if the license text is missing.
      #
      def metadata_plist_item
        return nil unless @spec and @license_text
        {
          name: @spec.name,
          version: @spec.version.to_s,
          authors: Hash[@spec.authors.map { |k, v| [k, v || ""] }],
          socialMediaURL: @spec.social_media_url || "",
          summary: @spec.summary,
          licenseType: @spec.license[:type],
          licenseText: @license_text,
          homepage: @spec.homepage
        }
      end

      # @return [Hash] the acknowledgement info for the Settings.bundle plist.
      # @return [Nil] if the license text is missing.
      #
      def settings_plist_item
        return nil unless @spec and @license_text
        {
          Title: @spec.name,
          Type: "PSGroupSpecifier",
          FooterText: @license_text
        }
      end

    end
  end
end
