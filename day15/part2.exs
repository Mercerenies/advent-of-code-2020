
defmodule State do
  defstruct turn: 1, data: %{}, previous: 0

  def starting_state do
    %State{}
  end

  def insert_number(state, n) do
    data = if state.turn == 0 do state.data else Map.put(state.data, state.previous, state.turn) end
    %State{turn: state.turn + 1, data: data, previous: n}
  end

  def insert_numbers(state, numbers) do
    Enum.reduce(numbers, state, fn(n, state) -> insert_number(state, n) end)
  end

  def next_number(state) do
    case Map.get(state.data, state.previous) do
      nil -> 0
      turn -> state.turn - turn
    end
  end

  def insert_next_number(state) do
    insert_number state, next_number(state)
  end

  def nth_number(state, n) do
    if state.turn == n do
      next_number state
    else
      nth_number insert_next_number(state), n
    end
  end

end

defmodule Runner do

  def run do
    initial_input = [0, 13, 16, 17, 1, 10, 6]
    initial_state = State.starting_state |> State.insert_numbers(initial_input)
    IO.puts(State.nth_number(initial_state, 30000000))
  end

end

Runner.run
