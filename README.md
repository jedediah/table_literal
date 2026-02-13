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

Pass a definiton block to the global method `Table` (or `Table::Definition.new`).
If that block takes an argument, the definition methods will be callable on that argument:
```RUBY
Table { |t|
  t.th # ...
  t.td # ...
}
```
Otherwise, the definition methods will be on `self` inside the block, as in all following examples.

Call `th` (or `head`) to define column keys,
and `td` (or `data`) to define rows of respective data.
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

`th` does not accept duplicate keys.
`td` requires the same number of arguments as the last `th`.

### Extra Data

`tx` (or `extra`) defines key/value pairs that are included in every subsequent output row:

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

Passing `_` as an argument to `td` omits that column's key from the output row,
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
`_` (or `ignore`) is a method that returns a special token object,
which can also be referenced as `Table::IGNORE`.

### Repeats

Passing ``` `` ``` (two backticks, AKA ditto mark) as an argument to `td` repeats the last value in that column:

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
``` `` ``` returns a special token object,
which is also returned from `repeat` or `”` (U+201D right double quotation mark),
or referenced as `Table::REPEAT`.

Note that ``` `` ``` calls the operator method `` #` `` with an empty string argument, which is handled as a special case.
If there is anything between the backticks, the call will be delegated to the default implementation,
typically the one in `Kernel` that runs a shell command.

## Using Tables

`Table { ... }` returns an instance of `Table::Definition`, which is `Enumerable`.
Every time this object is enumerated, the definition block is evaluated.

To simply get an `Array` of `Hash`es for the table, call  `to_a`.

Calling `each` with a block yields each row of the table as a `Hash`, as it is defined.
The result of the `each` block is returned from the `td` call inside the definition block.
This allows products of table rows to be passed back and used for subsequent rows.
See [FactoryBot Integration](#factorybot-integration) for an example of how this can be useful.

Calling `each` without a block returns an `Enumerator`, as usual.

`Table::Definition` also implements `call`, which does the same thing as `each`,
except it requires a block argument, and it returns the result of the definition block.

## [FactoryBot](https://github.com/thoughtbot/factory_bot) Integration

This is what table literals were made for:

```RUBY
require 'table/factory_bot'

test "something about users" do
  users = create_table :user, :with_some_trait do
            th :name,       :email,               :supervisor,   :hired_at
    alice = td 'Alice',     'alice@woot.com',     nil,           _ 
            td 'Bob',       'bob@woot.com',       alice,         alice.hired_at + 1.year
            td 'Charlie',   'charlie@woot.com',   ``,            alice.hired_at + 2.years
            td 'Dexter',    'dexter@woot.com',    ``,            alice.hired_at + 5.years
  end
  
  # ...
end
```
Require the optional library `table/factory_bot` to extend FactoryBot with a `*_table` method for each strategy,
That includes default strategies (`create_table`, `build_table`, `attributes_for_table`, etc.)
and custom strategies registered through `FactoryBot.register_strategy()`.

These `*_table` methods take a factory name, zero or more trait names, and a table definition block.
Each `td` runs the factory with the given overrides, and returns the factory product.
An `Array` of all products is returned from the `*_table` method.

Using `_` in the table will omit the attribute override for that row, allowing the factory to generate it.

The product returned from `td` can be referenced in later rows, as demonstrated above with `alice`.

Tables are super nice for lists of examples with several overrides.
With stock FactoryBot, it's much harder to fit each example on a single line,
so you typically end up with something like this:

```RUBY
users = [
  alice = create(
    :user, :with_some_trait,
    name: 'Alice',
    email: 'alice@woot.com',
    supervisor: nil
  ),
  create(
    :user, :with_some_trait,
    name: 'Bob',
    email: 'bob@woot.com',
    supervisor: alice,
    hired_at: alice.hired_at + 1.year
  ),
  create(
    :user, :with_some_trait,
    name: 'Charlie',
    email: 'charlie@woot.com',
    supervisor: alice,
    hired_at: alice.hired_at + 2.years
  ),
  create(
    :user, :with_some_trait,
    name: 'Dexter',
    email: 'dexter@woot.com',
    supervisor: alice,
    hired_at: alice.hired_at + 5.years
  )
]
```

## TODO

* RuboCop plugin to automate table alignment.
  Formatting by hand is tedious, and easy to neglect e.g. after find and replace.
* Ruby/FactoryBot version requirements
