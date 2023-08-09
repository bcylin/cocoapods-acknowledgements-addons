default:
	make install-dependencies
	open App.xcworkspace

install-dependencies:
	git submodule update --init --recursive
	brew list mint > /dev/null || brew install mint
	mint bootstrap
	mint run carthage bootstrap --platform ios --no-build
	bundle install
	bundle exec pod install
