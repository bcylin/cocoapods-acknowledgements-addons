default:
	make install-dependencies
	open App.xcworkspace

install-dependencies:
	git submodule update --init --recursive
	carthage bootstrap --platform ios --no-build
	bundle exec pod install
