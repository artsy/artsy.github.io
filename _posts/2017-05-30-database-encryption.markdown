---
layout: post
title: "Database Encryption"
date: 2017-05-30 11:03
comments: true
author: ashkan
categories: [Database, Encryption, Security]
---

After examining the data stored in one of our systems, we realized it can potentially include some sensitive user data. To reduce the number of people that are technically able to access the data and reduce the risks associated with a potential data theft, we decided to encrypt data getting persisted in the database.

# Our Goal
Encrypt database without any downtime.

<!-- more -->

# Approach
While we want to encrypt existing rows, new rows are constantly being added to our database. In order to reach our goal without downtime there was a clear path:

1. Add new _encrypted_ fields to the database.
2. Start populating new _encrypted_ fields with _encrypted_ values while still populating _non-encrypted_ fields.
3. Migrate old rows by populating their _encrypted_ fields.
4. Refactor to use _encrypted_ fields.
5. Drop _non-encrypted_ fields.

Each step above is relatively simple and can be tested properly before moving to the next step.

## Choosing an Encryption Library
We looked at few gems, mainly [attr_encrypted](https://github.com/attr-encrypted/attr_encrypted), [crypt_keeper](https://github.com/jmazzi/crypt_keeper) and [symmetric-encryption](https://github.com/rocketjob/symmetric-encryption).

While all these libraries were reliable, we used **Symmetric Encryption**, based on its robust [documentation](https://rocketjob.github.io/symmetric-encryption/), ease of use and easy integration with other libraries (in our case ActiveRecord). It provides some useful [Rake tasks](https://rocketjob.github.io/symmetric-encryption/rake_tasks.html) for configurations inside/outside of Heroku. Overall [`symmetric-encryption`](https://github.com/rocketjob/symmetric-encryption) seemed really 🔒 .

## Configuration
`config/symmetric-encryption.yml` is used to define what algorithm to use and where to find the related keys for different environments.

Symmetric Encryption uses OpenSSL to encrypt and decrypt the data which means we are able to use any of the algorithms supported by OpenSSL. We used `aes-256-cbc` which is also recommended default algorithm.

In order to create one run:

```bash
rails generate symmetric_encryption:new_keys production
```

Generated key above SHOULD NOT be committed into source code. Depending on how your application is deployed, there are two approaches for storing this key. On both scenarios keys are encrypted before storing on file/environment variable. Secret used for encrypting encryption key can be committed into source code.

### Outside of Heroku
Key can be stored on a file on disk outside of source code. We can use `key_filename` in configuration `yml` to point to this file. In this scenario we would use operating system to limit access to key file.

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
     MIIEpAIBAAKCAQEAxIL9H/jYUGpA38v6PowRSRJEo3aNVXULNM/QNRpx2DTf++KH
     6DcuFTFcNSSSxG9n4y7tKi755be8N0uwCCuOzvXqfWmXYjbLwK3Ib2vm0btpHyvA
     qxgqeJOOCxKdW/cUFLWn0tACUcEjVCNfWEGaFyvkOUuR7Ub9KfhbW9cZO3BxZMUf
     IPGlHl/gWyf484sXygd+S7cpDTRRzo9RjG74DwfE0MFGf9a1fTkxnSgeOJ6asTOy
     fp9tEToUlbglKaYGpOGHYQ9TV5ZsyJ9jRUyb4SP5wK2eK6dHTxTcHvT03kD90Hv4
     WeKIXv3WOjkwNEyMdpnJJfSDb5oquQvCNi7ZSQIDAQABAoIBAQCbzR7TUoBugU+e
     ICLvpC2wOYOh9kRoFLwlyv3QnH7WZFWRZzFJszYeJ1xr5etXQtyjCnmOkGAg+WOI
     k8GlOKOpAuA/PpB/leJFiYL4lBwU/PmDdTT0cdx6bMKZlNCeMW8CXGQKiFDOcMqJ
     0uGtH5YD+RChPIEeFsJxnC8SyZ9/t2ra7XnMGiCZvRXIUDSEIIsRx/mOymJ7bL+h
     Lbp46IfXf6ZuIzwzoIk0JReV/r+wdmkAVDkrrMkCmVS4/X1wN/Tiik9/yvbsh/CL
     ztC55eSIEjATkWxnXfPASZN6oUfQPEveGH3HzNjdncjH/Ho8FaNMIAfFpBhhLPi9
     nG5sbH+BAoGBAOdoUyVoAA/QUa3/FkQaa7Ajjehe5MR5k6VtaGtcxrLiBjrNR7x+
     nqlZlGvWDMiCz49dgj+G1Qk1bbYrZLRX/Hjeqy5dZOGLMfgf9eKUmS1rDwAzBMcj
     M9jnnJEBx8HIlNzaR6wzp3GMd0rrccs660A8URvzkgo9qNbvMLq9vyUtAoGBANll
     SY1Iv9uaIz8klTXU9YzYtsfUmgXzw7K8StPdbEbo8F1J3JPJB4D7QHF0ObIaSWuf
     suZqLsvWlYGuJeyX2ntlBN82ORfvUdOrdrbDlmPyj4PfFVl0AK3U3Ai374DNrjKR
     hF6YFm4TLDaJhUjeV5C43kbE1N2FAMS9LYtPJ44NAoGAFDGHZ/E+aCLerddfwwun
     MBS6MnftcLPHTZ1RimTrNfsBXipBw1ItWEvn5s0kCm9X24PmdNK4TnhqHYaF4DL5
     ZjbQK1idEA2Mi8GGPIKJJ2x7P6I0HYiV4qy7fe/w1ZlCXE90B7PuPbtrQY9wO7Ll
     ipJ45X6I1PnyfOcckn8yafUCgYACtPAlgjJhWZn2v03cTbqA9nHQKyV/zXkyUIXd
     /XPLrjrP7ouAi5A8WuSChR/yx8ECRgrEM65Be3qBEtoGCB4AS1G0NcigM6qhKBFi
     VS0aMXr3+V8argcUIwJaWW/x+p2go48yXlJpLHPweeXe8mXEt4iM+QZte6p2yKQ4
     h9PGQQKBgQCqSydmXBnXGIVTp2sH/2GnpxLYnDBpcJE0tM8bJ42HEQQgRThIChsn
     PnGA91G9MVikYapgI0VYBHQOTsz8rTIUzsKwXG+TIaK+W84nxH5y6jUkjqwxZmAz
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
Since we don't have access to file system in Heroku outside of source code, `symmetric-encryption` suggests to set encryption key as an environment variable. Configuration is same as above except we replace `key_filename` with `encrypted_key: "<%= ENV['PRODUCTION_ENCRYPTION_KEY1'] %>"`.

You can use following rake task to generate Heroku specific configuration file:
```
rails g symmetric_encryption:heroku_config
```
This will create `config/symmetric-encryption.yml` file and also output commands you can run to set _encrypted_ encryption key on Heroku as an environment variable.


For someone in order to be able to decode the data:


- They have to be able to access our database.
- They need to be able to access our source code.
- They need to be able to access key files on disk or Heroku's configuration.

### ActiveRecord Integration
Symmetric Encryption provides a seamless integration with `ActiveRecord`, we can use `attr_encrypted` helper method to define _encrypted_ fields. Lets say we wanted to encrypt a `Note` model that has `note` and `subject`, you can add following to your `ActiveRecord` model:

```ruby
# app/models/note.rb
attr_encrypted :note
attr_encrypted :subject
```

This means whenever you set `note` for this model `symmetric-encryption` will set `encrypted_note` field in the database. Whenever you retrieve an instance of this model, `symmetric-encryption` will decrypt `encrypted_note` field and you can access _decrypted_ value by just accessing `note`.

In our case we couldn't use this helper immediately, the issue is, using `encrypted_attr` means we will no longer be able to use un-encrypted fields. In our migration process until 4th step we still use non-encrypted fields and we need to populate them. In order to do that we started with adding a `before_validation` callback to our model to set encrypted fields based on un-encrypted ones.

```ruby
# app/models/note.rb
before_validation :encrypt_notes_fields

def encrypt_note_fields
  self.encrypted_note = SymmetricEncryption.encrypt(note, true, true, :string)
  self.encrypted_subject = SymmetricEncryption.encrypt(subject, true, true, :string)
end

validates :encrypted_note, symmetric_encryption: true, if: :note?
validates :encrypted_subject, symmetric_encryption: true, if: :subject?
```
In the above code `SymmetricEncryption.encrypt(note, true, true, :string)` means encrypt `note` field, use random IV, compress the string and also use string when decrypting.

Those two `validates` methods above make sure that we don't allow setting un-encrypted values for those encrypted fields.

Once we got the the 4th step and stopped populating/reading un-encrypted fields we can easily switch above to

```ruby
# app/models/note.rb
attr_encrypted :note
attr_encrypted :subject
```

# Query encrypted fields
Generally when we encrypt a field we can't do a partial query on the content of that field. On the other hand if we use the same IV ([Initialization Vector](https://en.wikipedia.org/wiki/Initialization_vector)) each time we encrypt a value, we can do a exact match query. Using same IV means encrypting the same value always end up with the same encrypted string. If exact match query is not something you need, the recommended approach is to use random IV for each encryption.


# Conclusion
With this approach we were able to encrypt a database with ~1.5 million rows without any downtime in about a week.
