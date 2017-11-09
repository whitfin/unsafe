defmodule Unsafe.Generator do
  @moduledoc """
  Quick and easy unsafe function binding generation.

  This module provides the compilation hooks for unsafe function
  generation. It provides a simple `use` interface to include and
  uses the `Unsafe.Compiler` to parse all definitions.

  Please see `Unsafe` for documentation and examples.
  """
  alias Unsafe.Compiler

  # Hook for the `use` syntax, which will automatically configure
  # the calling module to use the attributes required for generation.
  defmacro __using__(options) do
    quote location: :keep do
      @before_compile Unsafe.Generator
      @unsafe_options unquote(options)

      Module.register_attribute(__MODULE__, :unsafe, [ accumulate: true ])
    end
  end

  # The compiler hook which will invoke the main compilation phase
  # found in `Unsafe.Compiler.compile/3` to compile the definitions.
  defmacro __before_compile__(%{ module: module } = env) do
    binding = Module.get_attribute(module, :unsafe)

    options =
      module
      |> Module.get_attribute(:unsafe_options)
      |> Kernel.||([])

    Compiler.compile!(env, binding, options)
  end
end
