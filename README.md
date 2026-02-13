# Table Literals
A concise and legible syntax for literal tabular data in Ruby, e.g.

```RUBY
require 'table'

Table {
  th :name,       :age,   :breed
  td 'Abby',      2,      'tabby'
  td 'Boots',     5,      'tuxedo'
  td 'Checkers',  1,      'persian'
}.to_a
```

evaluates to

```RUBY
[
  {name: "Abby", age: 2, breed: "tabby"},
  {name: "Boots", age: 5, breed: "tuxedo"},
  {name: "Checkers", age: 1, breed: "persian"}
]
```

This kind of literal data appears particularly often in tests, when creating lists of example objects
(see [FactoryBot Integration](#factorybot-integration)).

## Defining Tables

Pass a definiton block to `Table::Definition.new`, or to the global method `Table`.
If that block takes an argument, the definition methods will be callable on that argument:
```RUBY
Table { |t|
  t.th # ...
  t.td # ...
}
```
Otherwise, the definition methods will be on `self` inside the block, as in all following examples.

Call `#th` or `#head` to define column keys, and `#td` or `#data` to define rows of respective data.
Column keys can be any object that is usable as a `Hash` key.
Columns can change in the middle of the block.

```RUBY
Table {
  th :alpha, 'bravo', Complex
  td 1,      2,       3
  td 4,      5,       6
  
  th :delta, :echo
  td 7,      8
}.to_a
```
```RUBY
[
  {alpha: 1, "bravo" => 2, Complex => 3},
  {alpha: 4, "bravo" => 5, Complex => 6},
  {delta: 7, echo: 8}
]
```

`#th` does not accept duplicate keys.
`#td` requires the same number of arguments as the last `#th`.

### Extra Data

`#tx` or `#extra` defines key/value pairs that are included in every subsequent output row:

```RUBY
Table {
  tx x: 0, y: 1 
  
  th :a, :b
  td 2,  3
  td 4,  5
}.to_a
```
```RUBY
[
  {x: 0, y: 1, a: 2, b: 3},
  {x: 0, y: 1, a: 4, b: 5}
]
```
Extra data can be changed anywhere in the definition block.
Table data takes priority over extra data with the same key. 

### Ignores

Passing `_` as an argument to `#td` omits that column's key from the output row,
or uses the respective extra data, if available:

```RUBY
Table {
  tx a: 0
  
  th :a, :b, :c
  td _,  2,  3
  td 4,  _,  6
  td 7,  8,  _
}.to_a
```
```RUBY
[
  {a: 0, b: 2, c: 3},
  {a: 4, c: 6},
  {a: 7, b: 8}
]
```
`#_` is a method that returns a token object `Table::IGNORE`.
You can also get this object from `#ignore`, or reference it directly.

### Repeats

Passing ``` `` ``` (two backticks, AKA ditto mark) as an argument to `#td` repeats the last value in that column:

```RUBY
Table {
  th :a, :b, :c
  td 1,  2,  3
  td ``, 5,  6
  td ``, ``, 9
}.to_a
```
```RUBY
[
  {a: 1, b: 2, c: 3},
  {a: 1, b: 5, c: 6},
  {a: 1, b: 5, c: 9}
]
```
``` `` ``` returns a token object `Table::REPEAT`.
You can also get this object from `#repeat`, `#”` (U+201D right double quotation mark), or reference it directly.

Note that ``` `` ``` calls the method `` #` `` with an empty string argument, which is handled as a special case.
If there is anything between the backticks, the call will be forwarded to `super`, which is typically ``Kernel#` ``.

## Using Tables

`Table { ... }` returns an instance of `Table::Definition`, which is `Enumerable`.
Every time this object is enumerated, the definition block is evaluated.

To simply get an `Array` of `Hash`es for the table, call  `#to_a`.

Calling `#each` with a block yields each row of the table as a `Hash`, as it is defined.
The result of the `#each` block is returned from the `#td` call inside the definition block.
This allows products of table rows to be passed back and used for subsequent rows.
See [FactoryBot Integration](#factorybot-integration) for an example of how this can be useful.

Calling `#each` without a block returns an `Enumerator`, as usual.

`Table::Definition` also implements `#call`, which does the same thing as `#each`,
except it requires a block argument, and it returns the result of the definition block.

## FactoryBot Integration

This is what table literals were made for:

```RUBY
require 'factory_bot'
require 'table/factory_bot'

FactoryBot.create_table :user, :with_some_trait do
          th :name,       :email,                 :birthday
  alice = td 'Alice',     'alice@woot.com',       _ 
          td 'Bob',       'bob@thingy.com',       alice.birthday + 1.year
          td 'Charlie',   'charlie@thingy.com',   alice.birthday + 2.years
end
```
```
[#<User:Alice ...>, #<User:Bob ...>, #<User:Charlie ...>]
```
Require the optional library `table/factory_bot` to extend FactoryBot with `*_table` methods,
that run factories with overrides provided in table syntax.
This supports default strategies (`create_table`, `build_table`, `attributes_for_table`, etc.)
as well as custom strategies registered through `FactoryBot.register_strategy()`.

These methods all take a factory name as the first argument, and trait names as additional arguments.
They return an `Array` of whatever the respective strategy returns.

Using `_` in the table will omit the attribute override for that row, allowing the factory to generate it.

The factory output is also returned from each `#td` in the table,
and can be used to derive the following rows, as demonstrated above with `alice`.

## TODO

* RuboCop plugin to automate table alignment.
  Doing it by hand can be tedious, and easy to neglect e.g. after find and replace.
* Ruby/FactoryBot version requirements
