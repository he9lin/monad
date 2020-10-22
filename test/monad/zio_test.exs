defmodule Monad.ZioTest do
  use ExUnit.Case, async: true

  require Monad.Zio, as: Zio
  import Zio

  doctest Zio

  test "Monad.Zio zio identity" do
    f = fn x -> fn _ -> {:ok, x * x} end end
    a = 2
    m = return a
    assert run(10, bind(m, f)) == run(10, f.(a))
  end

  test "Monad.Zio ok identity" do
    m = return 42
    assert run(10, bind(m, &return/1)) == run(10, m)
  end

  test "Monad.Zio associativity" do
    f = fn x -> return(x * x) end
    g = fn x -> return(x - 1) end
    m = return 2
    assert run(10, bind(m, f) |> bind(g)) == run(10, bind(m, &bind(f.(&1), g)))
  end

  test "Monad.Zio successful bind" do
    assert run(4, (Zio.m do
                     x <- return 2
                     y <- ask()
                     return (x * y)
                   end)) == {:ok, 8}
  end

  test "Monad.Zio failing bind" do
    assert run(4, (Zio.m do
                     x <- fn _ -> {:error, 2} end
                     y <- ask()
                     return x * y
            end)) == {:error, 2}
  end

  test "Monad.Zio.fail" do
    assert run(4, (Zio.m do
                     x <- fail "reason"
                     y <- ask()
                     return x * y
            end)) == {:error, "reason"}
  end
end
