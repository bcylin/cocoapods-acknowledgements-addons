default: install
	open App.xcworkspace

install:
	git submodule update --init --recursive
	carthage bootstrap --platform ios --no-build
	bundle install
	bundle exec pod install
