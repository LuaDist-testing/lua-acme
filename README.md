Introduction
============

This is a Lua implementation of the ACME protocol. It is mainly in the
form of a library, but includes a client tool as well.

Library API
===========

acme.account
------------

This module abstracts an ACME account and is the main entrypoint to all
interaction with the ACME server. A single `new()` method is exposed,
which takes an Lua-OpenSSL `openssl.pkey`, ACME directory URL and an
optional HTTPS request function as arguments.

The HTTPS support from LuaSec will be used by default.

``` {.lua}
local acme_account = require "acme.account"
local ossl_pkey = require "openssl.pkey"

local account_key = ossl_pkey.new({ bits = 2048 });
local account = acme_account.new(account_key, "https://acme.api.example/directory");
```

Sevral methods and properties are available on the `account` object for
interacting with the ACME server. Some offer higher levels of
abstraction than others.

### Properties

`account_key`
:   The account key given to `new()`.

`directory_url`
:   The ACME directory URL given to `new()`.

`nonces`
:   Stack of nonces for use with signed requests.

### High level method

`register(contacts...)`
:   Register the account with the ACME server. Takes an arbitrary number
    of contact detail URIs as arguments, eg `mailto:` or `tel:` URIs.
    Returns a table with HTTP response data.

`new_dns_auth(name)`
:   Request a new authorization for a DNS name. A successful response
    will most likely contains challenges.

`new_authz({type=..., value = ...})`
:   Request a new arbitrary authorization. You probably want to use
    `new_dns_authz()` instead.

### Low level methods

`step(object, [url])`
:   Perform a single signed ACME request. Looks up `object.resource` in
    ACME directory if no `url` is given.

`get_directory()`
:   Fetches the directory. Done automatically if not done yet. Also used
    to replenish `nonces`.

`get_key_authz(token)`
:   Returns the key authorization string from a token. Used
    for challenges.

`signed_request(object, url)`
:   Does a signed HTTPS request.

`unsigned_request(url, post_body)`
:   Does the actual HTTPS request, handles nonces and errors.

luacme client/tool
==================

An example / proof of concept client is included. It is not fully ready
but might work for you, or may require customization to work in your
environment.

Register with service
---------------------

First you need to create the account file and register it with the ACME
server:

    luacme account.json register https://acme.api.example/directory mailto:certmaster@example.com

Request a certificate
---------------------

Then you can begin requesting certificates:

    luacme account.json getcert www.example.com

Currently, you will be asked to complete challenges yourself. The paths
given may vary.
