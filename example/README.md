# Example iOS app

### Podfile

```rb
plugin "cocoapods-acknowledgements-addons",
  add: ["Acknowledgements", "Carthage/Checkouts", "Dependencies"],
  exclude: ["QuickTableViewController"]
```

The plugin finds additional acknowledgements from the following directories:

```
.
├── Acknowledgements
│   └── Crypto
├── Carthage
│   └── Checkouts
│       ├── Alamofire
│       ├── Crypto
│       └── QuickTableViewController
├── Dependencies
│   └── Strongify
├── Podfile
└── Podfile.lock
```

* [`Crypto`](https://github.com/soffes/Crypto) is not available via CocoaPods. `Acknowledgements/Crypto/Crypto.podspec` provides the acknowledgement info.
* `Alamofire` is ignored since it's already in Podfile.
* `QuickTableViewController` is excluded from the list.
* `Strongify` installed via git-submodule will be added to the acknowledgements.

### Launch the project

```sh
make install && open App.xcworkspace
```
