defmodule Unsafe do
  @moduledoc """
  Generate unsafe bindings for Elixir functions.

  This library aims to simplify the generation of unsafe function
  definitions (which here means "functions which can crash"). This
  is done by code generation at compile time to lessen the bloat in
  the main source tree, and to remove the cognitive load from the
  developers.

  Generation will create function signatures ending with a `!` per
  the Elixir standards, and forward the results of the safe function
  through to a chosen handler to deal with crashes.

  ### Generation

  Registering functions for unsafe generation is as easy as using
  the `@unsafe` module attribute.

      defmodule MyModule do
        use Unsafe.Generator,
          docs: false

        @unsafe [
          { :test, 1, :unwrap }
        ]

        def test(true),
          do: { :ok, true }
        def test(false),
          do: { :ok, false }

        defp unwrap({ _, bool }),
          do: bool
      end

  The code above will generate a compile time signature which looks
  like the following function definition (conceptually):

      def test!(arg0) do
        unwrap(test(arg0))
      end

  Thus making all of the following true in practice:

      # clearly we keep the main definition
      MyModule.test(true)  == { :ok, true }
      MyModule.test(false) == { :ok, false }

      # and the unsafe versions
      MyModule.test!(true)  == true
      MyModule.test!(false) == false

  ### @unsafe

  The `@unsafe` attribute is used to define which functions should
  have their signatures wrapped. Values set against this attribute
  *must* define the function name and arity, with an optional handler.

  The following are all valid definitions of the `@unsafe` attribute:

      # single function binding
      @unsafe { :test, 1 }

      # many function bindings
      @unsafe [ { :test, 1 } ]

      # many function arities
      @unsafe [ { :test, [ 1, 2 ] } ]

      # explicit private (defp) handler definitions
      @unsafe [ { :test, 1, :my_handler } ]

      # explicit public (def) handler definitions
      @unsafe [ { :test, 1, { MyModule, :my_handler } }]

      # explicit argument names (for documentation)
      @unsafe [ { :test, [ :value ] } ]

  It should also be noted that all of the above will accumulate which
  means that you can use `@unsafe` as many times and in as many places
  as you wish inside a module. In addition, you can use `@unsafe_binding`
  in place of `@unsafe` if preferred (due to historical reasons).

  ### Options

  The use hook accepts options as a way to pass global options to all
  `@unsafe` attribute hooks inside the current module. These options
  will modify the way code is generated.

  The existing option set is limited, and is as follows:

    * `docs` - whether or not to enable documentation for the generated
      functions. By default docs are disabled, so the unsafe functions
      are hidden from your documentation. If enabled, you should name
      your arguments instead of providing just an arity.

    * `handler` - a default handler to apply to all `@unsafe` bindings
      which do not have an explicit handler set. This is useful if
      all of your definitions should use the same handler.
  """
end
