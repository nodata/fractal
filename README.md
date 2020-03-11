# Fractal

[![Build Status](https://github.com/nodata/fractal/workflows/CI/badge.svg)](https://github.com/nodata/fractal/actions)
[![CocoaPods Platform](https://img.shields.io/cocoapods/p/Fractal)](#)
[![CocoaPods Version](https://img.shields.io/cocoapods/v/Fractal)](/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![MIT License](https://img.shields.io/github/license/nodata/fractal?color=informational)](/LICENSE)


An iOS Design System based on Atomic Design Theory and Declarative UI.

## Installation

### Carthage

```
github "nodata/fractal"
```

### CocoaPods

```
pod 'Fractal'
```

## Usage

1. Create a `Brand` 
2. Build Atomic Components as plain old `UIView` / `UIViewController` subclasses
3. Create `Sections` using the `ViewSection` `ViewControllerSection` protocols
4. Add `SectionBuilder` to your main `UIViewController`
5. Create a declaritive array of `Sections` that display your Atomic Components in a `UITableView` or `UICollectionView`

Please visit the in built TestApp to see various implementations of Sections.

## Reference
http://atomicdesign.bradfrost.com/

## Progress
| Epics | |
----|---- 
| DesignSystem | ✅ |
| SectionSystem | ✅ |
| SandboxApp | ✅ |
| Tests | WIP |

| Branding | |
----|---- 
| Colors | ✅ |
| Fonts | ✅ |
| Sizes | ✅ |
| Spacing & Autolayout | ✅ |
| Brand injection | ✅ |
| DateFormat | WIP |

| Atomic Elements |  |
----|---- 
| Button | ✅ |
| Label | ✅ |
| SegmentedControl | ✅ |
| Slider | ✅ |
| Switch | ✅ |
| TextField | ✅ |
| TextView | ✅ |

| Section interpretation | |
----|---- 
| UITableView | ✅ |
| UICollectionView | ✅ |
| UIStackView in UIScrollView | Maybe |
| UIViewController | Maybe |

## Contributors

[nodata](https://github.com/nodata)

[cantallops](https://github.com/cantallops)

[danielsinclairtill](https://github.com/danielsinclairtill)

[plimc](https://github.com/plimc)

[jeffreybergier](https://github.com/jeffreybergier)

[herbal7ea](https://github.com/herbal7ea)

[bricklife](https://github.com/bricklife)

[timoliver](https://github.com/timoliver)

[musbaalbaki](https://github.com/musbaalbaki)

## License

Copyright 2019 Anthony Smith, Mercari, Inc. Licensed under the MIT License. 
