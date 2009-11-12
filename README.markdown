Keychain Plugin for Quick Search Bar
====================================

This adds basic support for keychain operations, including copying of username and
password to the clipboard.

Binary Installation
-------------------

1. <a href="http://cloud.github.com/downloads/dwalters/qsb-mac-keychain-plugin/KeychainItems-0.1.zip">Download the prebuilt binary</a>.
2. Extract it.
3. Move the `KeychainItems.hgs` to `~/Library/Application Support/Google/Quick Search Box/PlugIns`.
4. Restart QSB.

Building from Source
--------------------

Build requirements are the same as other plugins - namely, you'll need a checkout of the QSB source tree and `QSBBUILDROOT` and `QSBSRCROOT` defined in your Xcode preferences.  See the [Xcode template instructions](http://qsb-mac.googlecode.com/svn/trunk/QuickSearchBox/QSB/SDK/Templates/QSBPlugin/README.txt) for further details.

Copy the resulting `KeychainItems.hgs` bundle from `build/Release` to your `~/Library/Application Support/Google/Quick Search Box/PlugIns` directory and restart QSB.
