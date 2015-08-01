defmodule Hydra.UsersPool do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    supervise([], strategy: :one_for_one)
  end

  def start_users(0, _, _, payload), do: :ok
  def start_users(n, link, method, payload) do
    Task.Supervisor.start_child(Hydra.UsersSupervisor, fn ->
      Hydra.User.start(link, method, payload)
    end)
    start_users(n - 1, link, method, payload)
  end

  def terminate_users do
    Supervisor.which_children(Hydra.UsersSupervisor) |> Enum.each(fn ({_,u, _, _}) -> Process.exit(u, :kill)  end)
  end
end
