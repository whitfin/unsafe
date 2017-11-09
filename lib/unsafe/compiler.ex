defmodule Unsafe.Compiler do
  @moduledoc """
  Compilation module for unsafe function definitions.

  This module shouldn't be interacted with by the developer, it's for
  internal use only. To generate unsafe definitions, you should go via
  the `Unsafe.Generator` module and the included hooks.
  """

  # definitions for multiple arities
  @type arities :: arity | [ arity ]

  # definitions for function definition bindings
  @type binding :: { atom, arities } | { atom, arities, handler }

  # definitions for handler functions
  @type handler :: atom | { atom, atom }

  @doc """
  Compiles a set of unsafe function definitions.

  Due to the bindings being pulled from module attributes, this function
  will accept nested lists of binding definitions and unpack as needed.
  """
  @spec compile!(Macro.Env.t, binding | [ binding ], Keyword.t) :: Macro.t
  def compile!(env, bindings, options) when is_list(bindings),
    do: Enum.map(bindings, &compile!(env, &1, options))

  # This will fire if the provided binding does not contain a
  # valid handler. If this is the case, the handler option will
  # be pulled from the binding options and passed through as the
  # handler to use for the binding (without any validation).
  def compile!(env, { name, arity }, options),
    do: compile!(env, { name, arity, options[:handler] }, options)

  # This definition fires when the provided binding includes a list of
  # arities and unpacks them into a list of bindings per arity. It then
  # just passes the results through to the same compile!/3 function
  # in order to make use of the same processing as any other bindings.
  def compile!(env, { name, [ head | _ ] = arity, handler }, options)
  when is_integer(head) do
    arity
    |> Enum.map(&{ name, &1, handler })
    |> Enum.map(&compile!(env, &1, options))
  end

  # This is the main definition which will compile a binding into a new
  # unsafe function handle, ready to be included in a module at compile
  # time. Arguments are generated based on the arity list provided and
  # passed to the main function reference, before being passed through
  # a validated handler and being returned from the unsafe function.
  def compile!(env, { name, arity, handler }, options) do
    # determine whether we have arguments or arity
    { enum, length, generator } =
      if is_list(arity) do
        # use an accepted arguments list with provided name definitions
        { arity, length(arity), &Macro.var(&1, env.module) }
      else
        # create an argument list based on the arity; [ arg0, arg1, etc... ]
        { 0..(arity && arity - 1), arity, &Macro.var(:"arg#{&1}", env.module) }
      end

    # generate the parameters used to define the proxy
    params = Enum.map(enum, generator)

    # create a defintion for the proxy; apply(env.module, name, params)
    result = quote do: apply(unquote(env.module), unquote(name), unquote(params))

    # generate the handler definition
    handle = case handler do
      # private function names as atoms
      func when is_atom(func) and not is_nil(func) ->
        # can be through of as func(result)
        quote do: unquote(func)(unquote(result))

      # public functions
      { mod, func } ->
        # can be thought of as apply(mod, func, [ result ])
        quote do: apply(unquote(mod), unquote(func), [unquote(result)])

      # bad definitions
      _fail ->
        raise CompileError, [
          description: "Invalid handler definition for #{name}/#{length}",
          file: env.file,
          line: env.line
        ]
    end

    # generate documentation tags
    ex_docs = if options[:docs] do
      # use a forwarding documentation message based on the function definition
      quote do: @doc "Unsafe proxy definition for `#{unquote(name)}/#{unquote(length)}`."
    else
      # disable documentation
      quote do: @doc false
    end

    # compile
    quote do
      # unpack the docs
      unquote(ex_docs)

      # add the function definition and embed the handle inside
      def unquote(:"#{name}!")(unquote_splicing(params)) do
        unquote(handle)
      end
    end
  end

  # Finally, if this definition fires, the provided definition
  # for the binding was totally invalid and should cause errors.
  def compile!(env, _invalid, _options),
    do: raise CompileError, [
      description: "Invalid function reference provided",
      file: env.file,
      line: env.line
    ]
end
