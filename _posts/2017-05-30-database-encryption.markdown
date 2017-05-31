---
layout: post
title: "Database encryption"
date: 2017-05-30 11:03
comments: true
author: ashkan
categories: [Databse, Encryption, Security]
---

Recently after examining the data stored in one of our systems, we noticed that while originally this system wasn't designed to include sensitive data, over the time it ended up including some sensitive information and we need to encrypt the data.

While our systems were safe by other means, because of the issue above we decided to encrypt the database behind it to cover the cases when people end up accessing our database directly.

# Our goal
Encrypt database without any downtime.

<!-- more -->

# Approach
In some ways this was a moving target, while we want to encrypt existing rows, new rows are constantly being added to our database. Because of that we ended up coming up with following steps:

1. Add new _encrypted_ fields to the database
2. Start populating new _encrypted_ fields with _encrypted_ values while still populating _non-encrypted_ fields
3. migrate old rows by populating their _encrypted_ fields
4. switch to use _encrypted_ fields
5. drop _non-encrypted_ fields

Each step above is relatively simple and can be tested properly before moving to the next step.

## Encryption Libraries and decision
We looked at few gems, mainly [attr_encrypted](https://github.com/attr-encrypted/attr_encrypted), [crypt_keeper](https://github.com/jmazzi/crypt_keeper) and [symmetric_encryption](https://github.com/rocketjob/symmetric-encryption). We looked at their documentation and also their stats in [RubyToolbox](https://www.ruby-toolbox.com/categories/encryption).

In the end, we decided to use **Symmetric Encryption**, mainly based on their robust [docs](https://rocketjob.github.io/symmetric-encryption/), ease of use and easy integration with other libraries (in our case ActiveRecord). They provide some useful [rake tasks](https://rocketjob.github.io/symmetric-encryption/rake_tasks.html) and also describe how to configure this gem for apps inside/outside Heroku. Overall `symmetric_encryption` seemed really robust, reliable and 🔒 .

## Using `symmetric_encryption`
Symmetric encryption provides a seemless integration with `ActiveRecord`, they provide `attr_encrypted` helper method which can be used to define _encrypted_ fields so you can add following to your `ActiveRecord` model:

```ruby
# app/models/note.rb
attr_encrypted :note
```
This means whenever you set `note` for this model `symmetric_encryption` will set `encrypted_note` field in the database. Whenever you retreive an instance of this model, `symmetric_encryption` will decrypt `encrypted_note` field and you can access _decrypted_ value by just accssing `note`.

But, in our case we couldn't use this helper immediatly, the issue is, using `encrypted_attr` means we will no longer be able to use un-encrypted fields. But in our migration process till 4th step we still have to populate non-encrypted fields along with encrypted ones. In order to do that we ended up starting with adding a `before_validation` callback to our `ActiveRecord` model which basically uses un-encrypted fields and populates/updates encrypted fields:

```ruby
# app/models/note.rb
before_validation :encrypt_notes_fields

def encrypt_message_fields
  self.encrypted_note = SymmetricEncryption.encrypt(note, true, true, :string)
  self.encrypted_subejct = SymmetricEncryption.encrypt(subject, true, true, :string)
end

validates :encrypted_note, symmetric_encryption: true, if: :note?
validates :encrypted_subejct, symmetric_encryption: true, if: :subject?
```

`validate` methods above makes sure that we don't allow setting un-encrypted values for those encrypted fields.

Once we got the the 4th step and stopped populating/reading un-encrypted fields we can easily swith above to

```ruby
# app/models/note.rb
attr_encrypted :note
attr_encrypted :subject
```

# Conclusion
With this approach we were able to encrypt a database with ~1.5 milion rows without any downtime in about a week.
