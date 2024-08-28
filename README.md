# Art Breaker 3000

## Credits

https://freemusicarchive.org/music/Komiku/Captain_Glouglous_Incredible_Week_Soundtrack

## Export notes

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

``
Code Signing: Code signing failed, see editor log for details.
Warning: unable to build chain to self-signed root for signer...
/Users/brianfoo/Library/Caches/Godot/Artbreaker3000/Artbreaker3000.app: errSecInternalComponent
```

Solution:

[Add intermediate signing certificate in your system keychain](https://stackoverflow.com/a/66083449)

### Android

```
keytool -v -genkey -keystore artbreaker.keystore -alias artbreaker -keyalg RSA -validity 10000
```