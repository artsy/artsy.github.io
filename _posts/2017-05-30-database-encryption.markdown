---
layout: post
title: "Encrypting ActiveRecord Fields Without Downtime."
date: 2017-05-30 11:03
comments: true
author: ashkan
categories: [Database, Encryption, Security]
---

After examining the data stored in one of our high-throughput systems, we realized it might include sensitive user data. To reduce the number of people that are technically able to access the data and reduce the risks associated with a potential data theft, we decided to encrypt certain database fields.

# Our Goal
Encrypt sensitive fields without any downtime.

<!-- more -->

# Approach
While we wanted to encrypt existing rows, new rows were constantly being added. In order to achieve zero downtown we have devised the following path:

1. Add new _encrypted_ fields to the database.
2. Start populating new _encrypted_ fields with _encrypted_ values while still populating _un-encrypted_ fields.
3. In the background, migrate existing records by populating their _encrypted_ fields.
4. Refactor to use _encrypted_ fields.
5. Drop _un-encrypted_ fields.

Each step above was relatively simple and was tested properly before moving to the next step.

## Choosing an Encryption Library
We looked at a few gems, mainly [attr_encrypted](https://github.com/attr-encrypted/attr_encrypted), [crypt_keeper](https://github.com/jmazzi/crypt_keeper) and [symmetric-encryption](https://github.com/rocketjob/symmetric-encryption).

While all these libraries were reliable, we used [symmetric-encryption](https://github.com/rocketjob/symmetric-encryption), based on its robust [documentation](https://rocketjob.github.io/symmetric-encryption/), ease of use and easy integration with other libraries (in our case `ActiveRecord`). It provides some useful [Rake tasks](https://rocketjob.github.io/symmetric-encryption/rake_tasks.html) for configurations inside/outside of Heroku. Overall `symmetric-encryption` seemed really 🔒 .

## Configuration
The `config/symmetric-encryption.yml` file is used to define what algorithm to use and where to find the related keys for different environments.

Symmetric Encryption uses OpenSSL to encrypt and decrypt the data which means we are able to use any of the algorithms supported by OpenSSL. We used `aes-256-cbc` which is also the recommended default algorithm.

In order to create a new set of keys:

```bash
rails generate symmetric_encryption:new_keys production
```

Above command will create an encryption key and an Initialization Vector ([IV](https://en.wikipedia.org/wiki/Initialization_vector)). Generated key **must not** be committed into source code. Depending on how your application is deployed, there are two approaches for storing this key. In both scenarios encryption keys are encrypted before storing on file/environment variable. Secret used for encrypting the encryption key itself can be committed into source code.

To access sensitive data, a malicious party would require access to:

- The database,
- Our source code,
- Encryption keys from files or configuration


### Outside of Heroku
Key can be stored in a file on disk outside of source code. We can use `key_filename` in configuration `yml` to point to this file. In this scenario we would use the operating system to limit access to key file.

Here is a sample configuration file:

```yml
#config/symmetric_encryption.yml


production:
  # Since the key to encrypt and decrypt with must NOT be stored along with the
  # source code, we only hold a RSA key that is used to unlock the file
  # containing the actual symmetric encryption key
  #
  # Sample RSA Key, DO NOT use this RSA key, generate a new one using
  #    openssl genrsa 2048
  private_rsa_key: |
     -----BEGIN RSA PRIVATE KEY-----
     MIIEpAIBAAKCAQEAxIL9H/jYUGpA38v6PowRSRJEo3aNVXULNM....
     r1URaMAun2PfAB4g2N/kEZTExgeOGqXjFhvvjdzl97ux2cTyZhaTXg==
     -----END RSA PRIVATE KEY-----

  # List Symmetric Key files in the order of current / latest first
  ciphers:
     -
        # Filename containing Symmetric Encryption Key encrypted using the
        # RSA public key derived from the private key above
        key_filename: /etc/rails/.rails.key
        iv_filename:  /etc/rails/.rails.iv

        # Encryption cipher_name
        #   Recommended values:
        #      aes-256-cbc
        #         256 AES CBC Algorithm. Very strong
        #         Ruby 1.8.7 MRI Approximately 100,000 encryptions or decryptions per second
        #         JRuby 1.6.7 with Ruby 1.8.7 Approximately 22,000 encryptions or decryptions per second
        #      aes-128-cbc
        #         128 AES CBC Algorithm. Less strong.
        #         Ruby 1.8.7 MRI Approximately 100,000 encryptions or decryptions per second
        #         JRuby 1.6.7 with Ruby 1.8.7 Approximately 22,000 encryptions or decryptions per second
        cipher_name:  aes-256-cbc

```

### On Heroku
Since the filesystem on Heroku is [ephemeral](https://devcenter.heroku.com/articles/dynos#ephemeral-filesystem), `symmetric-encryption` suggests to set encryption key as an environment variable. Configuration is same as above except we replace `key_filename` with `encrypted_key: "<%= ENV['PRODUCTION_ENCRYPTION_KEY1'] %>"`.

You can use the following rake task to generate a Heroku-specific configuration file:
```
rails g symmetric_encryption:heroku_config
```
This creates a `config/symmetric-encryption.yml` file and also outputs commands you can run to set the _encrypted_ encryption key on Heroku as an environment variable.


### ActiveRecord Integration
Symmetric Encryption provides a seamless integration with `ActiveRecord`. We can use `attr_encrypted` helper method to define _encrypted_ fields. Let's say we wanted to encrypt a `Note` model that has `note` and `subject`. You can add the following to your `ActiveRecord` model:

```ruby
# app/models/note.rb
attr_encrypted :note
attr_encrypted :subject
```

This means whenever you set `note` for this model `symmetric-encryption` will set `encrypted_note` field in the database. Whenever you retrieve an instance of this model, `symmetric-encryption` will decrypt `encrypted_note` field and you can access _decrypted_ value by just accessing `note`.

In our case we couldn't use this helper immediately. Using encrypted_attr would prevent us from directly accessing the existing, un-encrypted fields in our database (which is necessary through step 3 in our approach). To work around this, we started by adding a `before_validation` callback to our model to set encrypted fields based on un-encrypted ones.

```ruby
# app/models/note.rb
before_validation :encrypt_notes_fields

def encrypt_note_fields
  self.encrypted_note = SymmetricEncryption.encrypt(note, true, true, :string)
  self.encrypted_subject = SymmetricEncryption.encrypt(subject, true, true, :string)
end
```

In the above code `SymmetricEncryption.encrypt(note, true, true, :string)` means encrypt `note` field, use random IV(Initialization Vector), compress the string and also use string when decrypting.

Once we got to the 4th step and stopped populating/reading un-encrypted fields we can easily switch above to

```ruby
# app/models/note.rb
attr_encrypted :note
attr_encrypted :subject
```

# Query encrypted fields
Generally when we encrypt a field we can't do a partial query on the content of that field. On the other hand if we use the same IV each time we encrypt a value, we can do an exact match query. Using same IV means encrypting the same value always end up with the same encrypted string. If exact match query is not something you need, the recommended approach is to use random IV for each encryption.


# Conclusion
With this approach we were able to encrypt a database with ~1.5 million rows without any downtime in about a week.
