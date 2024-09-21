# Art Breaker 3000

[Art Breaker 3000](https://artbreaker.brianfoo.com/) is an app for demolishing and recycling famous artworks efficiently and beautifully. It was created by [Brian Foo](https://brianfoo.com/) in 2024. Music and audio courtesy of public domain music by [Komiku](https://freemusicarchive.org/music/Komiku/). Public domain artworks courtesy of [The Art Institute of Chicago](https://www.artic.edu/), [The Cleveland Art Museum](https://www.clevelandart.org/), [The Metropolitan Museum of Art](https://www.metmuseum.org/), [The National Gallery of Art](https://www.nga.gov/), and [The Smithsonian Institution](https://www.si.edu/). This app was created in [Godot](https://godotengine.org/) and the code is [open source](https://github.com/beefoo/art-breaker-3000/blob/main/LICENSE).

For a full list of credits, see [credits.md](https://github.com/beefoo/art-breaker-3000/blob/main/credits.md).

## Usage

To run the app, simply visit [artbreaker.brianfoo.com](https://artbreaker.brianfoo.com/) to use it in the browser or download desktop versions for Mac and PC.

If you'd like to "look under the hood" or make your own tweaks to the app, you will need to download [Godot](https://godotengine.org/). This app was developed using Godot 4.3, so any version of Godot 4.x should work.  Any other version of Godot (e.g. Godot 3.x) will require significant changes to the code.

Once you have Godot installed, clone this repository, open Godot, and select the subfolder `./art-breaker-3000/godot/` to view the project. You should be able to run it without any additional steps.

## Export notes

Some debug notes when exporting to different platforms.

### MacOS

Error:

```
Code Signing: Code signing failed, see editor log for details.
error: The specified item could not be found in the keychain.
```

Solution:

- [Download your certificate from Apple developer account](https://developer.apple.com/account/resources/certificates/list)
- Double click the downloaded certificate and add it to your `login` Keychain

Error:

```
Code Signing: Code signing failed, see editor log for details.
Warning: unable to build chain to self-signed root for signer...
/Users/<user>/Library/Caches/Godot/Artbreaker3000/Artbreaker3000.app: errSecInternalComponent
```

Solution:

[Add intermediate signing certificate in your system keychain](https://stackoverflow.com/a/66083449)

### Android

Uploading an APK to Google's Play Store requires you to sign using a non-debug keystore file; such file can be generated like this:

```
keytool -v -genkey -keystore artbreaker.keystore -alias artbreaker -keyalg RSA -validity 10000
```

### Web

The current project exports HTML5 app as a multi-threaded app with stream based audio. Multi-threaded web apps have been known to have issues with running on Mac/IOS devices. This also requires you to set two headers on the server:

```
Cross-Origin-Opener-Policy=same-origin
Cross-Origin-Embedder-Policy=require-corp
```

Alternatively, you can export as a single-threaded web app. To do this, turn off **Variant -> Thread Support** in the Web export settings. And change **Audio -> General -> Default Playback Type.web** to **Sample** in Project settings. This should be maximize compatibility, but removes all audio effects, which is a critical defect IMO.