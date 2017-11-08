defmodule Unsafe.Generator do
  alias Unsafe.Compiler

  defmacro __using__(_) do
    quote location: :keep do
      @before_compile Unsafe.Generator

      Module.register_attribute(__MODULE__, :unsafe, [ accumulate: true ])
      Module.register_attribute(__MODULE__, :unsafe_binding, [ accumulate: true ])
      Module.register_attribute(__MODULE__, :unsafe_options, [])
    end
  end

  defmacro __before_compile__(%{ module: module } = env) do
    defined = Module.get_attribute(module, :unsafe)

    binding =
      module
      |> Module.get_attribute(:unsafe_binding)
      |> Enum.concat(defined)
      |> List.flatten

    options =
      module
      |> Module.get_attribute(:unsafe_options)
      |> Kernel.||([])

    Compiler.compile(env, binding, options)
  end
end
