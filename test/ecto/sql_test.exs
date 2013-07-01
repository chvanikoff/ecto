Code.require_file "../test_helper.exs", __DIR__

defmodule Ecto.SQLTest do
  use ExUnit.Case, async: true

  import Ecto.Query
  alias Ecto.SQL

   defmodule Entity do
    use Ecto.Entity
    table_name :entity

    field :x, :integer
    field :y, :integer
  end

   defmodule Entity2 do
    use Ecto.Entity
    table_name :entity2
  end

  test "from" do
    query = from(r in Entity) |> select([r], r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM entity AS r"

    query = from(r in Entity) |> from(r2 in Entity2) |> select([r], r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM entity AS r, entity2 AS r2"
  end

  test "select" do
    query = from(r in Entity) |> select([r], {r.x, r.y})
    assert SQL.compile(query) == "SELECT r.x, r.y\nFROM entity AS r"

    query = from(r in Entity) |> select([r], {r.x, r.y + 123})
    assert SQL.compile(query) == "SELECT r.x, r.y + 123\nFROM entity AS r"
  end

  test "where" do
    query = from(r in Entity) |> where([r], r.x != nil) |> select([r], r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM entity AS r\nWHERE (r.x != NULL)"

    query = from(r in Entity) |> where([r], r.x == 42) |> where([r], r.y != 43) |> select([r], r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM entity AS r\nWHERE (r.x = 42) AND (r.y != 43)"
  end

  test "variable binding" do
    x = 123
    query = from(r in Entity) |> select([], x)
    assert SQL.compile(query) == "SELECT 123\nFROM entity AS r"

    query = from(r in Entity) |> select([r], x + r.y)
    assert SQL.compile(query) == "SELECT 123 + r.y\nFROM entity AS r"
  end

  test "string escape" do
    x = "'\\ \n"
    query = from(r in Entity) |> select([], x)
    assert SQL.compile(query) == "SELECT '''\\\\ \n'\nFROM entity AS r"

    query = from(r in Entity) |> select([], "'\\")
    assert SQL.compile(query) == "SELECT '''\\\\'\nFROM entity AS r"
  end

  test "unary ops" do
    query = from(r in Entity) |> select([r], +r.x)
    assert SQL.compile(query) == "SELECT +r.x\nFROM entity AS r"

    query = from(r in Entity) |> select([r], -r.x)
    assert SQL.compile(query) == "SELECT -r.x\nFROM entity AS r"
  end

  test "binary ops" do
    query = from(r in Entity) |> select([], 1 == 2)
    assert SQL.compile(query) == "SELECT 1 = 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 != 2)
    assert SQL.compile(query) == "SELECT 1 != 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 <= 2)
    assert SQL.compile(query) == "SELECT 1 <= 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 >= 2)
    assert SQL.compile(query) == "SELECT 1 >= 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 < 2)
    assert SQL.compile(query) == "SELECT 1 < 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 > 2)
    assert SQL.compile(query) == "SELECT 1 > 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 + 2)
    assert SQL.compile(query) == "SELECT 1 + 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 - 2)
    assert SQL.compile(query) == "SELECT 1 - 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 * 2)
    assert SQL.compile(query) == "SELECT 1 * 2\nFROM entity AS r"

    query = from(r in Entity) |> select([], 1 / 2)
    assert SQL.compile(query) == "SELECT 1 / 2\nFROM entity AS r"
  end

  test "literals" do
    query = from(r in Entity) |> select([], :atom)
    assert SQL.compile(query) == "SELECT atom\nFROM entity AS r"

    query = from(r in Entity) |> select([], nil)
    assert SQL.compile(query) == "SELECT NULL\nFROM entity AS r"

    query = from(r in Entity) |> select([], true)
    assert SQL.compile(query) == "SELECT true\nFROM entity AS r"

    query = from(r in Entity) |> select([], false)
    assert SQL.compile(query) == "SELECT false\nFROM entity AS r"

    query = from(r in Entity) |> select([], "abc")
    assert SQL.compile(query) == "SELECT 'abc'\nFROM entity AS r"

    # TODO: Test more numbers
    query = from(r in Entity) |> select([], 123)
    assert SQL.compile(query) == "SELECT 123\nFROM entity AS r"
  end

  test "nested expressions" do
    z = 123
    query = from(r in Entity) |> select([r], r.x + (r.y + -z) - 3)
    assert SQL.compile(query) == "SELECT (r.x + (r.y + -123)) - 3\nFROM entity AS r"
  end
end
