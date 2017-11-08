defmodule Unsafe.Compiler do

  @type arities :: arity | [ arity ]

  @type binding :: { atom, arities } | { atom, arities, handler }

  @type handler :: atom | { atom, atom }

  @spec compile(Macro.Env.t, [ binding ], Keyword.t) :: Macro.t
  def compile(env, bindings, options) do
    bindings
    |> List.wrap
    |> Enum.map(&do_compile!(env, &1, options))
  end

  defp do_compile!(env, { name, arity }, options),
    do: do_compile!(env, { name, arity, options[:handler] }, options)

  defp do_compile!(env, { name, arity, handler }, options) when is_list(arity) do
    arity
    |> Enum.map(&{ name, &1, handler })
    |> Enum.map(&do_compile!(env, &1, options))
  end

  defp do_compile!(env, { name, arity, handler }, _options) do
    params = Enum.map(0..(arity - 1), &Macro.var(:"arg#{&1}", env.module))

    result = quote do
      apply(unquote(env.module), unquote(name), unquote(params))
    end

    handle = case handler do
      func when is_atom(func) and not is_nil(func) ->
        quote do: unquote(func)(unquote(result))

      { mod, func } ->
        quote do: apply(unquote(mod), unquote(func), [unquote(result)])

      _invalid ->
        raise CompileError, [
          description: "Invalid handler definition for #{name}/#{arity}",
          file: env.file,
          line: env.line
        ]
    end

    quote do
      @doc false
      def unquote(:"#{name}!")(unquote_splicing(params)) do
        unquote(handle)
      end
    end
  end

  defp do_compile!(env, _invalid, _options),
    do: raise CompileError, [
      description: "Invalid function reference provided",
      file: env.file,
      line: env.line
    ]
end
