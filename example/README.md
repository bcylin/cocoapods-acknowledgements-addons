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
│   └── Crypto (with podspec)
├── Carthage
│   └── Checkouts
│       ├── Alamofire
│       ├── Crypto
│       └── QuickTableViewController (ignored)
├── Dependencies
│   └── Strongify
├── Podfile
└── Podfile.lock
```

### Launch the project

```sh
make install && open App.xcworkspace
```
