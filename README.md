# lobcfc
A CFML wrapper for the [Lob API](https://lob.com/docs).  
Wrap the Lob API to verify addresses and send physical mail programmatically.

*This is an early stage wrapper, initially developed for a conference demo. Feel free to use the issue tracker to report bugs or suggest improvements!*

### Acknowledgements

This project borrows heavily from the API frameworks built by [jcberquist](https://github.com/jcberquist), such as [xero-cfml](https://github.com/jcberquist/xero-cfml) and [aws-cfml](https://github.com/jcberquist/aws-cfml). Because it draws on those projects, it is also licensed under the terms of the MIT license.

## Table of Contents

- [Quick Start](#quick-start)
- [`lobcfc` Reference Manual](#reference-manual)

## Quick Start
Lob's API can do a lot. Here's a quick example of building an address, adding it to your account, and then listing all addresses.

```cfc
  address = new path.to.lobcfc.helpers.address()
    .description( 'Conference Demo' )
    .company( 'Hard Rock Hotel & Casino Las Vegas' )
    .name( 'T. S. Eliot' )
    .address( '4455 Paradise Road')
    .city( 'Las Vegas' ).state( 'Nevada' ).zip( '89169' );

  lob = new path.to.lobcfc.lob( live_apiKey = 'xxx', test_apiKey = 'xxx' );

  adresses = lob.listAddresses();
  writeDump( var='#adresses#' );
```

## Reference Manual

#### `createAddress( required any address )`
Creates a new address object. The address parameter should be an instance of the `helpers.address` component. However, if you want to create and pass in the struct or json yourself, you can.

#### `deleteAddress( required string id )`
Permanently deletes an address. It cannot be undone.

#### `listAddresses( numeric offset = 0, numeric limit, boolean includeTotal, struct metadata, struct dateFilter )`
Returns a list of your addresses. The addresses are returned sorted by creation date, with the most recently created addresses appearing first.

#### `createPostcard( required string id )`
Create a new postcard. The postcard parameter should be an instance of the `helpers.postcard` component. However, if you want to create and pass in the struct or json yourself, you can.

---
