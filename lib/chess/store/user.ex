defmodule Chess.Store.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Comeonin.Argon2

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :games, Chess.Store.Game
    has_many :games_as_opponent, Chess.Store.Game, foreign_key: :opponent_id

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, registration_attrs())
    |> validate_required(registration_attrs())
    |> unique_constraint(:email)
    |> hash_password()
  end

  def profile_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, profile_attrs())
    |> validate_required(profile_attrs())
    |> unique_constraint(:email)
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password])
    |> validate_required([:password])
    |> hash_password()
  end

  def opponents(user) do
    from user in "users",
      where: user.id != ^user.id,
      select: {user.name, user.id}
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)
    if password do
      changeset
      |> change(Argon2.add_hash(password))
    else
      changeset
    end
  end

  defp registration_attrs, do: ~w[name email password]a
  defp profile_attrs, do: ~w{name email}a
end
