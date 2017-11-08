defmodule Unsafe do
  defmacro __using__(_) do
    quote location: :keep do
      @before_compile Unsafe

      Module.register_attribute(__MODULE__, :unsafe, [ accumulate: true ])
      Module.register_attribute(__MODULE__, :unsafe_opts, [])
    end
  end

  defmacro __before_compile__(env) do
    default_handler =
      env.module
      |> Module.get_attribute(:unsafe_opts)
      |> Kernel.||([])
      |> Keyword.get(:handler)

    validate_handler!(env, default_handler)

    flat_definition =
      env.module
      |> Module.get_attribute(:unsafe)
      |> List.flatten
      |> Enum.flat_map(&transform_bindings!(env, &1, default_handler))

    for { name, arity, handler } <- flat_definition do
      argidx = Enum.map(0..(arity - 1), &Macro.var(:"arg#{&1}", env.module))

      result = quote do
        apply(unquote(env.module), unquote(name), unquote(argidx))
      end

      handle = case handler do
        { mod, func } ->
          quote do: apply(unquote(mod), unquote(func), [unquote(result)])
        func ->
          quote do: unquote(func)(unquote(result))
      end

      quote do
        @doc false
        def unquote(:"#{name}!")(unquote_splicing(argidx)) do
          unquote(handle)
        end
      end
    end
  end

  defp compile_error!(env, desc) do
    raise CompileError, [
      file: env.file,
      line: env.line,
      description: desc
    ]
  end

  defp transform_bindings!(env, { name, arity }, handler) do
    case handler do
      nil ->
        [ first_arity | _ ] = List.wrap(arity)
        compile_error!(env, "Unable to locate handler for #{name}/#{first_arity}")
      fun ->
        transform_bindings!(env, { name, arity, fun }, fun)
    end
  end
  defp transform_bindings!(env, { name, arity, handler }, _handler) do
    validate_handler!(env, handler)
    arity
    |> List.wrap
    |> Enum.map(&{ name, &1, handler })
  end

  defp validate_handler!(_env, { mod, func } = handler) when is_atom(mod) and is_atom(func),
    do: handler
  defp validate_handler!(_env, handler) when is_atom(handler),
    do: handler
  defp validate_handler!(env, _handler),
    do: compile_error!(env, "Invalid handler definition")
end
