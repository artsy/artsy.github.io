---
layout: post
title: "Database Encryption"
date: 2017-05-30 11:03
comments: true
author: ashkan
categories: [Database, Encryption, Security]
---

After examining the data stored in one of our systems, we noticed that while originally it wasn't designed to include potentially sensitive user data, eventually it ended up including some and we need to encrypt the data.

To reduce the number of people that are technically able to examine the data and help reduce the risks associated with a potential data theft, data needs to be encrypted before getting persisted in the database.

# Our Goal
Encrypt database without any downtime.

<!-- more -->

# Approach
In some ways this was a moving target, while we want to encrypt existing rows, new rows are constantly being added to our database. Because of that we ended up coming up with following steps:

1. Add new _encrypted_ fields to the database
2. Start populating new _encrypted_ fields with _encrypted_ values while still populating _non-encrypted_ fields
3. Migrate old rows by populating their _encrypted_ fields
4. Refactor to use _encrypted_ fields
5. Drop _non-encrypted_ fields

Each step above is relatively simple and can be tested properly before moving to the next step.

## Choosing an Encryption Library
We looked at few gems, mainly [attr_encrypted](https://github.com/attr-encrypted/attr_encrypted), [crypt_keeper](https://github.com/jmazzi/crypt_keeper) and [symmetric_encryption](https://github.com/rocketjob/symmetric-encryption). We looked at their documentation and also their stats in [RubyToolbox](https://www.ruby-toolbox.com/categories/encryption).

In the end, we decided to use **Symmetric Encryption**, mainly based on their robust [docs](https://rocketjob.github.io/symmetric-encryption/), ease of use and easy integration with other libraries (in our case ActiveRecord). They provide some useful [rake tasks](https://rocketjob.github.io/symmetric-encryption/rake_tasks.html) and also describe how to configure this gem for apps inside/outside Heroku. Overall [`symmetric-encryption`](https://github.com/rocketjob/symmetric-encryption) seemed really robust, reliable and 🔒 .

Symmetric Encryption uses OpenSSL to encrypt and decrypt the data which means we are able to use any of the encryption algorithms supported by OpenSSL.

## Configuration
As mentioned above, we can configure our encryption algorithm for being deployed in Heroku and outside of it. The main difference is, outside of Heroku were we may have access to file system outside of source code we can configure encryption differently.

### Outside of Heroku
`symmetric-encryption` expects the encryption key to be stored on a file on disk outside of source code and expects OS to deal with security of that file.

### In Heroku
Since we don't have access to file system in Heroku outside of source code, `symmetric-encryption` suggests to add encryption key in environment variable BUT in order to do that we need to encrypt the encryption key. Secret used for encrypting encryption key can be committed into source code this means for someone in order to be able to decode the data:
- They have to be able to access our database
- They need to be able to access our source code
- They need to be able to access Heroku's configuration

### ActiveRecord integration
Symmetric encryption provides a seamless integration with `ActiveRecord`, it provides `attr_encrypted` helper method which can be used to define _encrypted_ fields. Lets say we wanted to encrypt a `Note` model that has `note` and `subject`, you can add following to your `ActiveRecord` model:

```ruby
# app/models/note.rb
attr_encrypted :note
attr_encrypted :subject
```

This means whenever you set `note` for this model `symmetric-encryption` will set `encrypted_note` field in the database. Whenever you retrieve an instance of this model, `symmetric-encryption` will decrypt `encrypted_note` field and you can access _decrypted_ value by just accessing `note`.

But, in our case we couldn't use this helper immediately, the issue is, using `encrypted_attr` means we will no longer be able to use un-encrypted fields. But in our migration process till 4th step we still have to populate non-encrypted fields along with encrypted ones. In order to do that we ended up starting with adding a `before_validation` callback to our `ActiveRecord` model which basically uses un-encrypted fields and populates/updates encrypted fields:

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
Generally when we encrypt a field we can't do a partial query on the content of that field. On the other hand if we use the same IV ([Initialization Vector](https://en.wikipedia.org/wiki/Initialization_vector)) each time we encrypt a value, which means encrypting the same value always end up with the same encrypted string, or if we store the IV that was used for encryption for that field, we can do a exact match query. If exact match query is not something you need, the recommended approach is to use random IV for each encryption.


# Conclusion
With this approach we were able to encrypt a database with ~1.5 million rows without any downtime in about a week.
