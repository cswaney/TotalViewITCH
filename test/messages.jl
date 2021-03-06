using TotalViewITCH: add!, complete!, to_csv
using Dates

date = Date("2010-01-01")

@testset "Messages" begin
    # setup
    orders = Dict{Int,Order}()
    add_message = Message(
        date,
        type = "A",
        name = "AAPL",
        side = "B",
        price = 125,
        shares = 500,
        refno = 123456789
    )
    add!(orders, add_message)

    # delete message
    delete_message = Message(
        date,
        type = "D",
        refno = 123456789
    )
    complete!(delete_message, orders)
    @test delete_message == Message(
        date,
        type = "D",
        name = "AAPL",
        side = "B",
        price = 125,
        shares = 500,
        refno = 123456789
    )

    # replace message
    replace_message = Message(
        date,
        type = "U",
        price = 115,
        shares = 200,
        refno = 123456789,
        newrefno = 987654321
    )
    _, delete_message, add_message = split(replace_message)
    complete!(delete_message, orders)
    complete!(add_message, orders)
    @test delete_message == Message(
        date,
        type = "D",
        name = "AAPL",
        side = "B",
        price = 125,
        shares = 500,
        refno = 123456789
    )
    @test add_message == Message(
        date,
        type = "A",
        name = "AAPL",
        side = "B",
        price = 115,
        shares = 200,
        refno = 987654321
    )

    # execute message
    execute_message = Message(
        date,
        type = "E",
        shares = 100,
        refno = 123456789
    )
    complete!(execute_message, orders)
    @test execute_message == Message(
        date,
        type = "E",
        name = "AAPL",
        side = "B",
        price = 125,
        shares = 100,
        refno = 123456789
    )

    # cancel message
    cancel_message = Message(
        date,
        type = "C",
        shares = 100,
        refno = 123456789
    )
    complete!(cancel_message, orders)
    @test cancel_message == Message(
        date,
        type = "C",
        name = "AAPL",
        side = "B",
        price = 125,
        shares = 100,
        refno = 123456789
    )
end

@testset "Messages.IO" begin
    add_message = Message(
        date,
        type = "A",
        name = "AAPL",
        side = "B",
        price = 125,
        shares = 500,
        refno = 123456789
    )
    @test to_csv(add_message) == "2010-01-01,-1,-1,A,.,AAPL,B,125,500,123456789,-1,."
end
