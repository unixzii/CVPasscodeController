# CVPasscodeController

A native looks passcode input interface.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Introduction

`CVPasscodeController` provide you with a easy way to achieve local authentication, which only requires you make little change in your project.

## Screencast
![](https://coding.net/u/cyandev/p/GitHubImageDelegate/git/raw/master/cvpasscodecontroller1.gif)
![](https://coding.net/u/cyandev/p/GitHubImageDelegate/git/raw/master/cvpasscodecontroller2.gif)

## Features
* Two interface style (dark / light).
* Supports arbitrary digits.
* Customizable interface strings.

## Example
To run the example project, clone the repo, and build the example scheme.

## Installation
CVPasscodeController is available through Carthage. To install it, simply add the following line to your Cartfile:

```bash
github "unixzii/CVPasscodeController"
```

## Usage Guide
`CVPasscodeController` is the main class you will work on.
Instantiate a `CVPasscodeController` object, pass a preferred style to its initializer.

`CVPasscodeEvaluating` is another important protocol you need to implement, it allow the controller evaluate the passcode.
One thing need to be concerned is your evaluating process should not block the main thread, it should return quickly. Before returning the result, you can schedule something that will happen after user input a correct passcode. For more, see the example project.

Any strings appear on the interface can be customized, only thing you need to do is implement `CVPasscodeInterfaceStringProviding` protocol.

After all thing is done, just present it as a view controller.

## License
The project is available under the MIT license. See the LICENSE file for more info.
