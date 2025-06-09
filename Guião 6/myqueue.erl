-module(myqueue).
-export{[create/0, enqueue/2, dequeue/1, test/0]}.

%create() ->
    [].


%enqueue([], Item) -> [Item];
%enqueue([H | T], Item) -> [H | enqueue(T, Item)].


%dequeue([]) -> empty;
%dequeue([H | T]) -> {T, H}.

create() -> {[], []}.

enqueue({In, Out}, Item) -> {[Item | In], Out}.

dequeue({In, [H | T]}) -> {{In, T}, H};
dequeue({[], []}) -> empty;
dequeue({In, []}) -> dequeue({[], lists:reverse(In)})

%reverse([]) -> [];
%reverse(L) -> reverse(L, []);
%reverse([], A) -> A;
%reverse([H | T], A) -> reverse(T, [H | A]).


test() ->
    Q0 = create(),
    Q1 = enqueue(Q0, 1),
    Q2 = enqueue(Q1, 2),
    Q3 = enqueue(Q2, 3),
    Q4 = enqueue(Q3, 4),
    Q5 = enqueue(Q4, 5),
    empty = dequeue(Q0),
    {Q6, 1} = dequeue(Q1),
    empty = dequeue(Q6),
    {Q7, 1} = dequeue(Q5),
    {Q8, 2} = dequeue(Q7),
    {Q9, 3} = dequeue(Q8),
    {Q10, 4} = dequeue(Q9),
    {Q11, 5} = dequeue(Q10),
    empty = dequeue(Q11),
    ok.