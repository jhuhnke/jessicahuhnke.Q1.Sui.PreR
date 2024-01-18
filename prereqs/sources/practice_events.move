module examples::tacos_with_events {
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    // This is the only dependency you need for events.
    use sui::event;

    /// For when Coin balance is too low.
    const ENotEnough: u64 = 0;

    /// Capability that grants an owner the right to collect profits.
    struct ShopOwnerCap has key { id: UID }

    /// A purchasable taco. For simplicity's sake we ignore implementation.
    struct taco has key { id: UID }

    struct tacoBell has key {
        id: UID,
        price: u64,
        balance: Balance<SUI>
    }

    /// For when someone has purchased a taco.
    struct tacoBought has copy, drop {
        id: ID
    }

    /// For when tacoBell owner has collected profits.
    struct ProfitsCollected has copy, drop {
        amount: u64
    }

    // ====== Functions ======

    fun init(ctx: &mut TxContext) {
        transfer::transfer(ShopOwnerCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::share_object(tacoBell {
            id: object::new(ctx),
            price: 1000,
            balance: balance::zero()
        })
    }

    /// Buy a taco.
    public fun buy_taco(
        shop: &mut tacoBell, payment: &mut Coin<SUI>, ctx: &mut TxContext
    ) {
        assert!(coin::value(payment) >= shop.price, ENotEnough);

        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);
        let id = object::new(ctx);

        balance::join(&mut shop.balance, paid);

        // Emit the event using future object's ID.
        event::emit(tacoBought { id: object::uid_to_inner(&id) });
        transfer::transfer(taco { id }, tx_context::sender(ctx))
    }

    /// Consume taco and get nothing...
    public fun eat_taco(d: taco) {
        let taco { id } = d;
        object::delete(id);
    }

    /// Take coin from `tacoBell` and transfer it to tx sender.
    /// Requires authorization with `ShopOwnerCap`.
    public fun collect_profits(
        _: &ShopOwnerCap, shop: &mut tacoBell, ctx: &mut TxContext
    ): Coin<SUI> {
        let amount = balance::value(&shop.balance);

        // simply create new type instance and emit it
        event::emit(ProfitsCollected { amount });
        coin::take(&mut shop.balance, amount, ctx)
    }
}