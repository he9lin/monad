defmodule Monad.Zio do
  use Monad
  use Monad.Pipeline

  @moduledoc """
  The Zio monad.

  Monad that encapsulates a read-only value/shared environment.

  ## Examples

      iex> require Monad.Zio, as: Zio
      iex> import Zio
      iex> r = Zio.m do
      ...>       let a = 2
      ...>       b <- ask()
      ...>       return a + b
      ...>     end
      iex> Zio.run(10, r)
      {:ok, 12}
  """

  # A zio is just a function that receives the read-only value and returns error_m
  @type zio_m(env, value, error) :: (env -> {:error, error} | {:ok, value})

  ## Monad implementations

  @spec bind(zio_m(any, any, any), (any -> zio_m(any, any, any))) :: zio_m(any, any, any)
  def bind(z, f) do
    fn x ->
      case z.(x) do
        {:ok, v} ->
          f.(v).(x)
        {:error, _} = err ->
          err
      end
    end
  end

  @doc """
  Inject `x` into a Zio monad.
  """
  @spec return(any) :: zio_m(any, any, any)
  def return(x), do: fn _ -> {:ok, x} end

  def env_return(x), do: fn _ -> x end

  ## Other functions

  @doc """
  Run Zio monad `r` by supplying it with value `x`.
  """
  @spec run(any, zio_m(any, any, any)) :: any
  def run(x, r), do: r.(x)

  @doc """
  Ask for the Zio monad's value.
  """
  @spec ask() :: zio_m(any, any, any)
  def ask(), do: fn x -> {:ok, x} end

  @doc """
  Set a different value locally for the Zio monad.
  """
  @spec local(zio_m(any, any, any), (any -> any)) :: zio_m(any, any, any)
  def local(r, f), do: fn x -> r.(f.(x)) end

  @doc """
  Signal failure, i.e. returns `{:error, msg}` wrapped in environment
  """
  @spec fail(any) :: zio_m(any, any, any)
  def fail(error), do: fn _ -> {:error, error} end

  @spec map_error(zio_m(any, any, any), (any -> any)) :: zio_m(any, any, any)
  def map_error(z, f) do
    fn r ->
      case z.(r) do
        {:ok, _} = ok -> ok
        {:error, err} -> {:error, f.(err)}
      end
    end
  end
end
