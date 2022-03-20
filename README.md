# Sweet Moon
[![Gem Version](https://badge.fury.io/rb/sweet-moon.svg)](https://badge.fury.io/rb/sweet-moon)

_Sweet Moon_ is a resilient solution that makes working with [Lua](https://www.lua.org) / [Fennel](https://fennel-lang.org) from [Ruby](https://www.ruby-lang.org) and vice versa a delightful experience.

![Image with Lua, Fennel, and Ruby source code examples.](https://raw.githubusercontent.com/gbaptista/assets/main/sweet-moon/sweet-moon.png)

- [Supported Versions](#supported-versions)
- [Setup and TLDR](#setup-and-tldr)
- [Loading Configuration Files](#loading-configuration-files)
  - [Lua Configuration Files](#lua-configuration-files)
  - [Fennel Configuration Files](#fennel-configuration-files)
- [Performance and Benchmarks](#performance-and-benchmarks)
  - [Fennel and Lua Versions](#fennel-and-lua-versions)
  - [Comparison with other Gems](comparison-with-other-gems)
- [Interacting with a Lua State](#interacting-with-a-lua-state)
  - [Setup](#setup)
  - [Exchanging Data](#exchanging-data)
    - [_eval_ and _load_](#eval-and-load)
    - [Primitives](#primitives)
    - [Tables, Arrays, and Hashes](#tables-arrays-and-hashes)
    - [Functions](#functions)
    - [Other Types](#other-types)
  - [_destroy_ and _clear_](#destroy-and-clear)
- [Modules, Packages and LuaRocks](#modules-packages-and-luarocks)
  - [Integration with LuaRocks](#integration-with-luarocks)
- [Fennel](#fennel)
  - [Fennel Usage](#fennel-usage)
  - [Fennel Setup](#fennel-setup)
- [Global vs Isolated](#global-vs-isolated)
- [Error Handling](#error-handling)
- [Where can I find .so files?](#where-can-i-find-so-files)
- [Low-Level C API](#low-level-c-api)
  - [The API](#the-api)
  - [Custom Shared Objects](#custom-shared-objects)
  - [Custom API References](#custom-api-references)
  - [Functions, Macros and Signatures](#functions-macros-and-signatures)
  - [Low-Level C API Example](#low-level-c-api-example)
    - [Lua 5.4](#lua-54)
    - [Lua 4.0](#lua-40)
- [Development](#development)

## Supported Versions

_Sweet Moon_ was created to be resilient and adaptable. So it doesn't have a dependency on specific versions, and it will always try to create a working environment with whatever you have available.

That said, these are the officially tested versions:

C API:
- Lua: `3.2.2`, `4.0.1`, `5.0.3`, `5.1.4`, and `5.4.2`

Interpreter:
- Lua: `5.0`, `5.1`, and `5.4`

Interpreters' Compatibility:
- Lua: `5.0.3`, `5.1.4`, `5.1.5`, `5.2.4`, `5.3.3`, `5.4.2`, and `5.4.4`
- LuaJIT: `2.0.5`

## Setup and TLDR

```sh
gem install sweet-moon
```

> **Disclaimer:** It's an early-stage project, and you should expect breaking changes.

```ruby
gem 'sweet-moon', '~> 0.0.1'
```

```ruby
require 'sweet-moon'

# State

SweetMoon.global.state.eval('return 1 + 2') # => 3
SweetMoon.global.state.fennel.eval('(+ 2 3)') # => 5

state = SweetMoon::State.new

state.eval('return 3 + 4') # => 7
state.load('file.lua') # => {...}

state.fennel.eval('(+ 3 7)') # => 10
state.fennel.load('file.fnl') # => {...}

# API

SweetMoon.global.api.luaL_newstate

api = SweetMoon::API.new

state = api.luaL_newstate
api.luaL_openlibs(state)
```

## Loading Configuration Files

Lua as a _Configuration Language_ is a robust approach widely used in the industry for [decades](https://www.lua.org/about.html). It's a powerful alternative to _[YAML](https://yaml.org)_ or _[TOML](https://toml.io)_ and way more spread and battle-tested than _[edn](https://github.com/edn-format/edn)_.

### Lua Configuration Files

Create a `.lua` file:

```lua
return {
  color = "red",
  dimensions = { width = 200, height = 2 * 80 },
  values = {4, 6} }
```

Load it:
```ruby
require 'sweet-moon'

SweetMoon.global.state.load('config.lua')

# => { 'color' => 'red',
#      'dimensions' => { 'width' => 200, 'height' => 160 },
#      'values' => [4, 6] }
```

Alternatively:
```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.load('config.lua')
```

### Fennel Configuration Files

Create a `.fnl` file:

```fnl
{:color "red"
 :dimensions {:width 200 :height (* 2 80)}
 :values [4 6]}
```

Load it:
```ruby
require 'sweet-moon'

SweetMoon.global.state.fennel.load('config.fnl')

# => { 'color' => 'red',
#      'dimensions' => { 'width' => 200, 'height' => 160 },
#      'values' => [4, 6] }
```

Alternatively:
```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.fennel.load('config.fnl')
```

## Performance and Benchmarks

Benchmarks created through [benchmark-ips](https://github.com/evanphx/benchmark-ips).

The task is to get a file with a source code equivalent to:
```lua
return {
  color = "red",
  dimensions = { width = 200, height = 2 * 80 },
  values = {4, 6} }
```

And then bring the final Ruby representation:
```ruby
{ 'color' => 'red',
  'dimensions' => { 'width' => 200, 'height' => 160 },
  'values' => [4, 6] }
```

It is important to note that only Lua and Fennel natively support expressions like `2 * 80`, and the other solutions have only a static number in their source.

### Fennel and Lua Versions

Higher is better:

![Image of a chart with Benchmarks between different Lua and Fennel versions.](https://raw.githubusercontent.com/gbaptista/assets/main/sweet-moon/lua-versions.png)

### Comparison with other Gems

Higher is better:

![Image of a chart with Benchmarks between Sweet Moon and other Gems.](https://raw.githubusercontent.com/gbaptista/assets/main/sweet-moon/other-gems.png)

Compared to: [rufus-lua](https://github.com/jmettraux/rufus-lua), [YAML](https://ruby-doc.org/stdlib-3.0.1/libdoc/yaml/rdoc/YAML.html), [edn-ruby](https://github.com/relevance/edn-ruby), [toml-rb](https://github.com/emancu/toml-rb), and [toml](https://github.com/jm/toml).

## Interacting with a Lua State

> Lua is a fast language engine with small footprint that you can [embed](https://www.lua.org/about.html) easily into your application.

- [Setup](#setup)
- [Exchanging Data](#exchanging-data)
  - [_eval_ and _load_](#eval-and-load)
  - [Primitives](#primitives)
  - [Tables, Arrays, and Hashes](#tables-arrays-and-hashes)
  - [Functions](#functions)
  - [Other Types](#other-types)
- [_destroy_ and _clear_](#destroy-and-clear)

### Setup

A state is composed of three key elements: `shared_object`, `api_reference`, and `interpreter`.

For the global state:
```ruby
require 'sweet-moon'

SweetMoon.global.config(
  shared_object: '/usr/lib/liblua.so.5.4.4',
  api_reference: '5.4.2',
  interpreter: '5.4'
)

SweetMoon.global.state.eval('return 1 + 1') # => 2
```

For a new isolated state:
```ruby
require 'sweet-moon'

state = SweetMoon::State.new(
  shared_object: '/usr/lib/liblua.so.5.4.4',
  api_reference: '5.4.2',
  interpreter: '5.4'
)

state.eval('return 1 + 1') # => 2
```
By default, _Sweet Moon_ will automatically identify all these elements and find the best possible combination for them. Usually, the only parameter you might want to set manually is the `shared_object`. To understand `shared_object` and `api_reference`, check [_Custom Shared Objects_](#custom-shared-objects).

The `interpreter` describes which version of _Sweet Moon's_ internal Interpreter will handle the interactions with the Lua state. The internal interpreter abstracts the Lua C API to provide methods like `state.eval`, `state.get`, etc.

_Sweet Moon_ may not have an interpreter for all Lua versions, especially the too old or very specific ones. For this scenario, an error will be raised:

```ruby
require 'sweet-moon'

SweetMoon::State.new(shared_object: '/usr/lib/liblua3.so')

# => SweetMoon::Errors::SweetMoonError
#    No compatible interpreter found for Lua C API 3.2.2
```

To check all available Interpreters, you can:

```ruby
require 'sweet-moon'

SweetMoon.meta.interpreters
# => ['5.0', '5.1', '5.4']
```

You can also check information about a state with:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.meta.shared_objects # => ['/usr/lib/liblua.so.5.4.4']
state.meta.api_reference # => 5.4.2
state.meta.interpreter   # => 5.4
state.meta.runtime       # => Lua 5.4

state.meta.to_h
# => { shared_objects: ['/usr/lib/liblua.so.5.4.4'],
#      api_reference: '5.4.2',
#      interpreter: '5.4',
#      runtime: 'Lua 5.4' }
```

The same is true for the global state with `SweetMoon.global.state.meta`.

### Exchanging Data

#### _eval_ and _load_

The `eval` method evaluates a Lua source code, and the `load` method loads a file and evaluates its content. Both return the output of the evaluation if it exists.

Caveat: The data exchange works through Lua [_global_](https://www.lua.org/pil/1.2.html) variables only.

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('return 2 + 2') # => 4
```

```lua
-- source.lua

from_lua = "Lua Text"

return { data = from_ruby }
```

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.set('from_ruby', 'Ruby Text')

state.load('source.lua') # => { 'data' => 'Ruby Text' }

state.get('from_lua') # => 'Lua Text'
```

#### Primitives

With `get` and `set`, you can exchange between Lua and Ruby the following primitive types:
- Lua: `string`, `integer`, `number`, `boolean`, and `nil`.
- Ruby: `String`, `Symbol`, `Integer`, `Float`, `TrueClass` (`true`), `FalseClass` (`false`), and `NilClass` (`nil`).

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('lua_value = "Lua Text"') # => nil

state.get('lua_value') # => 'Lua Text'

state.set(:ruby_value, 'Ruby Text') # => nil

state.eval('return ruby_value') # => 'Ruby Text'
```

Caveats:

- Ruby `Symbol` (e.g. `:value`) is converted to Lua `string`.
- [_Floating-point arithmetic_](https://en.wikipedia.org/wiki/Floating-point_arithmetic) may be tricky when exchanging numbers between two different environments.

#### Tables, Arrays, and Hashes

You can exchange `Array`, `Hash` and `table` with `get` and `set`.

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('lua_value = {a = "text", b = 1.5, c = true}') # => nil

state.get(:lua_value) # => { 'a' => 'text', 'b' => 1.5, 'c' => true }

state.eval('list = {"a", "b", "c"}') # => nil

state.get('list') # => ['a', 'b', 'c']

state.eval('empty = {}') # => nil

state.get(:empty) # => { }

state.set('ruby_array', [3, 'a', true]) # => nil

state.eval('return ruby_array[1]') # => 3
state.eval('return ruby_array[2]') # => 'a'

state.set('ruby_hash', { a: 'b', values: ['c', 'd'] }) # => nil

state.eval('return ruby_hash["values"][2]') # => 'd'
```

With `get`, you can use a second parameter to read a field:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('lua_value = {a = "text", b = 1.5, c = true}') # => nil

state.get(:lua_value, :b) # => 1.5
```

Caveats:

- Ruby `Symbol` (e.g. `:value`) is converted to Lua `string`.
- Ruby `Hash` is converted to Lua `table`.
- Ruby `Array` is converted to a _sequential_ Lua `table`.
- Lua _sequential_ `table` is converted to Ruby `Array`.
- Lua _non-sequential_ `table` is converted to Ruby `Hash`.
- Lua **empty** `table` is converted to `Hash` (`{}`).
- Lua _sequential_ `table` (_array_) [starts](https://www.lua.org/pil/2.5.html) at index `1`.

#### Functions

Lua [_Functions_](https://www.lua.org/pil/5.html) are converted to Ruby [_Lambdas_](https://docs.ruby-lang.org/en/3.1/Proc.html#class-Proc-label-Lambda+and+non-lambda+semantics), where the first parameter is an array of parameters, and the second is an optional expected number of results that default to 1 (Lua _Functions_ can return [multiple results](https://www.lua.org/pil/5.1.html)).

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('lua_fn = function(a, b) return "ok", a + b; end') # => nil

lua_fn = state.get(:lua_fn)

lua_fn.call([1, 2]) # => 'ok'
lua_fn.call([1, 2], 2) # => ['ok', 3]

lua_fn.([1, 2]) # => 'ok'
lua_fn.([1, 2], 2) # => ['ok', 3]

state.eval('second = function(list) return list[2]; end') # => nil

second = state.get(:second)

second.([%w[a b c]]) # => 'b'
```

You can call Ruby _Lambdas_ from _Lua_ as well:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

ruby_fn = lambda do |a, b|
  return a + b
end

state.set(:rubyFn, ruby_fn) # => nil

state.eval('return rubyFn(2, 2)') # => 4

sum_list = -> (list) { list.sum }

state.set('sumList', sum_list) # => nil

state.eval('return sumList({2, 3, 5})') # => 10
```

#### Other Types

We encourage you to keep a clean and simple exchange between Lua and Ruby, avoiding complex data types and bloated data structures.

Anytime you try to exchange an unsupported data type, you won't get an error, but it will be converted to a string representation:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('return coroutine.create(function() end)')
# => 'thread: 0x93924850822056'

state.set('ruby_thread', Thread.new { 1 + 1 })

state.eval('return ruby_thread') # => '#<Thread:0x0000000000000d0c>'
```

Also, avoid exchanging complex things unnecessarily, e.g., modules:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.require_module('fennel')

state.get(:fennel) # => {...}
# => It returns a huge chunk of data with
#    a complex structure and mixed data types.
#    It will work, but we encourage you to
#    avoid that.
```

Prefer instead to extract what you need only:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.require_module('fennel')

fennel_eval = state.get(:fennel, :eval)

fennel_eval.(['(+ 1 1)']) # => 2
```

You can also abstract what you need into global variables:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.require_module('fennel')

state.eval('fennel_eval = fennel.eval')

fennel_eval = state.get(:fennel_eval)

fennel_eval.(['(+ 1 1)']) # => 2
```

## _destroy_ and _clear_

You can destroy a state:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.set(:a, 1)
state.get(:a) # => 1

state.destroy

state.get(:a)
# => SweetMoon::Errors::SweetMoonError
#    The state no longer exists.
```

You can also clear a state:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.set(:a, 1)
state.get(:a) # => 1

state.clear

state.get(:a) # => nil
```

## Modules, Packages and LuaRocks

> Check the [Modules](https://www.lua.org/manual/5.4/manual.html#6.3) documentation at the _Lua Manual_ to understand the essentials.

You can achieve everything through eval:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('package.path = package.path .. ";/my-modules/?.lua"')
state.eval('package.cpath = package.cpath .. ";/my-modules/?.so"')

state.eval('some_package = require("my_module")')
```

Regardless, we offer some helpers that you can use.

Adding a path to the Lua [`package.path`](https://www.lua.org/manual/5.4/manual.html#pdf-package.path):

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.add_package_path('/home/me/my-lua-modules/?.lua')
state.add_package_path('/home/me/my-lua-modules/?/init.lua')

state.add_package_cpath('/home/me/my-lua-modules/?.so')

state.add_package_path('/home/me/fennel.lua')

state.add_package_cpath('/home/me/lib.so')

state.package_path
# => ['./?.lua',
 #    './?/init.lua',
 #    '/home/me/my-lua-modules/?.lua',
 #    '/home/me/my-lua-modules/?/init.lua',
 #    '/home/me/fennel.lua']

state.package_cpath
# => ['./?.so',
#     '/home/me/my-lua-modules/?.so',
#     '/home/me/lib.so']
```

Requiring a module:
```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.require_module('supernova')

state.require_module_as('fennel', 'f')
```

You can set packages in State constructors:

```ruby
require 'sweet-moon'

SweetMoon::State.new(
  package_path: '/folder/lib.lua',
  package_cpath: '/lib/lib.so',
)
```

Also, you can add packages through the global config:

```ruby
require 'sweet-moon'

SweetMoon.global.config(
  package_path: '/folder/lib.lua',
  package_cpath: '/lib/lib.so',
)
```

### Integration with LuaRocks:

> Read more about how to use LuaRocks in the official documentation: [_Using LuaRocks_](https://github.com/luarocks/luarocks/wiki/Using-LuaRocks)

[LuaRocks](https://luarocks.org) is a popular package manager for the Lua language.

You can install modules like [_supernova_](https://github.com/gbaptista/supernova#lua) with:

```sh
luarocks install supernova --local
```

You can figure out the path for LuaRocks modules with:
```sh
luarocks path
# => export LUA_PATH='.../home/me/.luarocks/share...
```

If you set the `LUA_PATH` and `LUA_CPATH` environment variable on your system, modules installed through LuaRocks will just work.

Alternatively, you can add it manually to the `package`:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.add_package_path('/home/me/.luarocks/share/lua/5.4/?.lua')
state.add_package_path('/home/me/.luarocks/share/lua/5.4/?/init.lua')
state.add_package_cpath('/home/me/.luarocks/lib/lua/5.4/?.so')

state.require_module('supernova')

state.eval('return supernova.enabled') # => true

state.require_module_as('supernova', 'sn')

state.eval('return sn.active_theme') # => 'default'

puts state.eval('return sn.red("hello")')  # => "\e[31mhello\e[0m"
puts state.eval('return sn.blue("hello")') # => "\e[34mhello\e[0m"
```

You can also use the constructor:
```ruby
require 'sweet-moon'

state = SweetMoon::State.new(
  package_path: [
    '/home/me/.luarocks/share/lua/5.4/?.lua',
    '/home/me/.luarocks/share/lua/5.4/?/init.lua'
  ],
  package_cpath: '/home/me/.luarocks/lib/lua/5.4/?.so'
)
```

For global:
```ruby
require 'sweet-moon'

SweetMoon.global.config(
  package_path: [
    '/home/me/.luarocks/share/lua/5.4/?.lua',
    '/home/me/.luarocks/share/lua/5.4/?/init.lua'
  ],
  package_cpath: '/home/me/.luarocks/lib/lua/5.4/?.so'
)
```


## Fennel

> _[Fennel](https://fennel-lang.org) is a programming language that brings together the speed, simplicity, and reach of [Lua](https://www.lua.org) with the flexibility of a [lisp syntax and macro system.](https://en.wikipedia.org/wiki/Lisp_(programming_language))_

### Fennel Usage

Everything described for Lua is equivalent to Fennel, and you have the same capabilities, methods, and data exchanging.

The only thing needed is to prefix your calls with `.fennel` and ensure that the Fennel module is available:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.fennel.eval('(+ 1 2)') # => 3

state.fennel.eval('(global mySum (fn [a b] (+ a b)))')
state.fennel.eval('(mySum 2 3)') # => 5

mySum = state.fennel.get(:mySum)

mySum.([4, 5]) # => 9

sum_list = -> (list) { list.sum }

state.set('sumList', sum_list) # => nil

state.fennel.eval('(sumList [2 3 5])') # => 10

state.fennel.load('file.fnl')
```

Alternatively:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new.fennel

state.eval('(+ 1 2)') # => 3
```

### Fennel Setup

To ensure that the Fennel module is available, you can set up the [_LuaRocks_](#integration-withluarocks) integration or manually add the `package_path` for the module.

You can download the `fennel.lua` file on the [Fennel's website](https://fennel-lang.org/setup#embedding-the-fennel-compiler-in-a-lua-application).

Manually:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.add_package_path('/folder/fennel.lua')

state.fennel.eval('(+ 1 1)') # => 2
```

With the constructor:

```ruby
require 'sweet-moon'

fennel = SweetMoon::State.new(package_path: '/folder/fennel.lua').fennel

fennel.eval('(+ 1 1)') # => 2
```

With global:

```ruby
require 'sweet-moon'

SweetMoon.global.state.add_package_path('/folder/fennel.lua')

SweetMoon.global.state.fennel.eval('(+ 1 1)') # => 2
```

Alternatively:

```ruby
require 'sweet-moon'

SweetMoon.global.config(package_path: '/folder/fennel.lua')

SweetMoon.global.state.fennel.eval('(+ 1 1)') # => 2
```

## Global vs Isolated

You can use the **global** helper that provides an _API_ and a _State_ for quick-and-dirty coding. It uses internally a Ruby [_Singleton_](https://docs.ruby-lang.org/en/3.1/Singleton.html):

```ruby
require 'sweet-moon'

SweetMoon.global.state.eval('return 1 + 1')

SweetMoon.global.api.luaL_newstate
```

You can configure **global** with:
```ruby
require 'sweet-moon'

SweetMoon.global.config(
  shared_object: '/usr/lib/liblua.so.5.4.4',
  api_reference: '5.4.2',
  interpreter: '5.4'
)
```

To clean up, you can:

```ruby
require 'sweet-moon'

SweetMoon.global.clear
```

As the API is just a stateless binding to the Lua C API, you can use it without worries.

You may want to use an isolated API for scenarios like interacting with two Lua versions simultaneously:

```ruby
require 'sweet-moon'

api_5 = SweetMoon::API.new(shared_object: '/usr/lib/liblua5.s')
api_3 = SweetMoon::API.new(shared_object: '/usr/lib/liblua3.so')

api_5.luaL_newstate

api_3.luaH_new
```

On the other hand, using the **global** _State_ may lead to a lot of issues. You need to consider from simple things – _"If I load two different files, the first file may impact the state of the second one?"_ – to more complex ones like multithreading, concurrency, etc.

So, you can at any time create a new isolated _State_ and destroy it when you don't need it anymore:

```ruby
require 'sweet-moon'

state = SweetMoon::State.new

state.eval('return 3 + 4') # => 7
state.load('file.lua') # => {...}

state.destroy
```

It's possible to empty a state with [_clear_](#destroy-and-clear).

Like the _API_, you may want to use an isolated _State_ to run Lua code in different Lua Versions simultaneously:

```ruby
require 'sweet-moon'

state_5 = SweetMoon::State.new(shared_object: '/usr/lib/liblua5.s')
state_3 = SweetMoon::State.new(shared_object: '/usr/lib/liblua3.so')

state_5.eval('return _VERSION') # => Lua 5.4
state_3.eval('return _VERSION') # => Lua 3.2
```


## Error Handling

These are – hopefully – all the possible errors:

```ruby
SweetMoonError # inherits from StandardError
LuaError # inherits from SweetMoonError

# inherits from LuaError:
LuaRuntimeError 
LuaMemoryAllocationError
LuaMessageHandlerError
LuaSyntaxError
LuaFileError
```

You can handle the errors from the `SweetMoon::Errors` namespace:

```ruby
require 'sweet-moon'

begin
  SweetMoon.global.state.eval('return 1 + true')
rescue SweetMoon::Errors::LuaRuntimeError => error
  puts error.message
  # => [string "return 1 + true"]:1: attempt to perform arithmetic on a boolean value
end
```

Or you can _include_ the errors for a cleaner version with `sweet-moon/errors`:

```ruby
require 'sweet-moon'
require 'sweet-moon/errors'

begin
  SweetMoon.global.state.eval('return 1 + true')
rescue LuaRuntimeError => error
  puts error.message
  # => [string "return 1 + true"]:1: attempt to perform arithmetic on a boolean value
end
```

## Where can I find .so files?

Due to the Lua's popularity, you likely have it already on your system, and _Sweet Moon_ will be able to find the files by itself.

Either way, you can download it from:
- [Lua Binaries](http://luabinaries.sourceforge.net)
- [LuaJIT releases](http://luajit.org/download.html)

## Low-Level C API

- [The API](#the-api)
- [Custom Shared Objects](#custom-shared-objects)
- [Custom API References](#custom-api-references)
- [Functions, Macros and Signatures](#functions-macros-and-signatures)
- [Low-Level C API Example](#low-level-c-api-example)
  - [Lua 5.4](#lua-54)
  - [Lua 4.0](#lua-40)

### The API

You can access a global instance of the low-level C API with:

```ruby
require 'sweet-moon'

SweetMoon.global.api
```

For a fresh new non-global instance:

```ruby
require 'sweet-moon'

api = SweetMoon::API.new
```

Informations about the API:

```ruby
api.meta.shared_objects # => ['/usr/lib/liblua.so.5.4.4']
api.meta.api_reference  # => '5.4.2'

api.meta.to_h

# => { shared_objects: ['/usr/lib/liblua.so.5.4.4'],
#      api_reference: '5.4.2' }
```

### Custom Shared Objects

> To learn more about _Shared Objects_ and `.so` files: [_Dynamic linking_](https://en.wikipedia.org/wiki/Library_(computing)#Dynamic_linking), [_Dynamic linker_](https://en.wikipedia.org/wiki/Dynamic_linker) and [_Executable and Linkable Format_](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format).

By default, _Sweet Moon_ will try to find and identify the Shared Object with the highest version available. You can customize it through:

```ruby
require 'sweet-moon'

api = SweetMoon::API.new(shared_object: '/usr/lib/liblua.so.5.4.4')
```

For the global instance:

```ruby
require 'sweet-moon'

SweetMoon.global.config(shared_object: '/usr/lib/liblua.so.5.4.4')

SweetMoon.global.api
```

Important to notice that the API Reference will not always be the same version of the Shared Object:

```ruby
require 'sweet-moon'

api = SweetMoon::API.new(shared_object: '/usr/lib/liblua.so.5.4.4')

api.meta.api_reference # => "5.4.2"
```

The Shared Object is from Lua **5.4.4**, and the API Reference is from Lua **5.4.2**.

This happens because it is impossible to extract function signatures from Shared Objects. So, _Sweet Moon_ will use an API Reference with the highest proportion of expected functions detected in the Shared Object as a reference.

A difference in versions, for practical purposes, is not a problem, given that _Sweet Moon_ has several relevant versions to choose from.

### Custom API References

You can force an specific API Reference for your Shared Object:

```ruby
require 'sweet-moon'

api = SweetMoon::API.new(
  shared_object: '/usr/lib/liblua.so.5.4.4',
  api_refence: '3.2.2'
)
api.meta.shared_objects # => ['/usr/lib/liblua.so.5.4.4']
api.meta.api_reference # => '3.2.2'
```

To check all available API References you can:

```ruby
require 'sweet-moon'

SweetMoon.meta.api_references
# => ['3.2.2', '4.0.1', '5.0.3', '5.1.4', '5.4.2']
```

_Sweet Moon_ won't raise errors by you trying to use an API Reference different from the Shared Object, but it will only attach valid functions, so you need to know what you are doing:

```ruby
require 'sweet-moon'

api_5 = SweetMoon::API.new(shared_object: '/usr/lib/liblua.so.5.4.4')

api_3 = SweetMoon::API.new(shared_object: '/usr/lib/liblua.so.3.2.2')

api_5_with_3 = SweetMoon::API.new(
  shared_object: '/usr/lib/liblua.so.5.4.4',
  api_reference: '3.2.2'
)

api_5.functions.size # => 159
api_3.functions.size # => 162
api_5_with_3.functions.size # => 20
```

### Functions, Macros, and Signatures

_Sweet Moon_ will provide the available Lua-related functions for a Shared Object:

```ruby
require 'sweet-moon'

api = SweetMoon::API.new(shared_object: '/usr/lib/liblua.so.5.4.4')

api.functions.size # 159

api.functions[0] # => :luaL_buffinitsize
api.functions[1] # => :luaL_prepbuffsize
api.functions[2] # => :luaL_checklstring
```

To check the signature of a function you can:

```ruby
api.signature_for(:luaL_checklstring)
# => { source: 'LUALIB_API const char *(luaL_checklstring) (lua_State *L, int arg, size_t *l);',
#      input: %i[pointer int pointer],
#      output: :pointer }

api.signature_for(:luaL_newstate)
# => { source: 'LUALIB_API lua_State *(luaL_newstate) (void);',
#      input: [],
#      output: :pointer }

api.signature_for(:lua_pop)
# => { source: '#define lua_pop(L,n) lua_settop(L, -(n)-1)',
#      macro: true,
#      requires: [
#        { source: 'LUA_API void (lua_settop) (lua_State *L, int idx);',
#          input: %i[pointer int],
#          output: :void }
#      ] }
```

Notice that `lua_pop` is a [macro](https://en.wikipedia.org/wiki/C_preprocessor), so the information about its signature is described differently.

### Low-Level C API Example

Working at a low-level with Lua will differ from version to version, and I recommend the book [_Programming in Lua_](https://www.lua.org/pil/) according to your target version. Chapters related to _"C API"_ are what you will probably search for, and the [_Lua Reference Manual_](https://www.lua.org/manual/) is [also](https://www.lua.org/manual/5.4/manual.html#4) a great [source](https://www.lua.org/manual/5.4/contents.html#index) of information.

#### Lua 5.4

As an example, following-ish [this reference](https://www.lua.org/pil/24.1.html), to get the result of the expression `math.pow(2, 3)`, you would do something like:

```ruby
require 'sweet-moon'

api = SweetMoon::API.new(shared_object: '/usr/lib/liblua.so.5.4.4')

state = api.luaL_newstate
api.luaL_openlibs(state)

api.luaL_loadstring(state, 'return math.pow(2, 3);')
api.lua_pcall(state, 0, 1, 0)

result = api.lua_tonumber(state, -1)

api.lua_pop(state)
api.lua_close(state)

puts result # => 8.0
```

This is a minimal example and does not consider things you probably should for production-ready purposes, like error handling, available stack space, type checking, etc.

#### Lua 4.0

As an example, following the [manual](https://www.lua.org/manual/4.0/manual.html#5.), to get the result of the expression `2 ^ 3`, you would do something like:

```ruby
require 'sweet-moon'

api = SweetMoon::API.new(
  shared_objects: ['/usr/lib/liblua4.so', '/usr/lib/liblualib4.so']
)

state = api.lua_open(0)

api.lua_mathlibopen(state)

api.lua_dostring(state, 'return 2 ^ 3')

result = api.lua_tonumber(state, -1)

api.lua_settop(state, -2)
api.lua_close(state)

puts result # => 8.0
```

Notice that two _Shared Objects_ were necessary for this Lua version, one for the _Standard API_ and another for the _Standard Libraries_.

This is a minimal example and does not consider things you probably should for production-ready purposes, like error handling, available stack space, type checking, etc.

## Development

```sh
bundle
rubocop -a
rspec
```

```sh
./ports/in/shell/sweet-moon version

bundle exec sweet-moon version

bundle exec sweet-moon signatures /lua/lib/542 542.rb

bundle exec ruby some/file.rb
```
