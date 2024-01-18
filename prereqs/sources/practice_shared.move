// Shared Object 
module examples::taco {
    use sui::transfer; 
    use sui::sui::SUI; 
    use sui::coin::{Self, Coin}; 
    use sui::object::{Self, UID}; 
    use sui::balance::{Self, Balance}; 
    use sui::tx_context::{Self, TxContext}; 

    // For when taco coin balance is way too low - everyone needs at least a little taco 
    const ENotEnough: u64 = 0; 

    // Grants owner the right to profit nugs from those tacos 
    struct ShopOwnerCap has key { id: UID }

    // Beefy 5 layers hot off the line 
    struct Taco has key { id: UID }

    // The taco bell, this is where the secret sauce is made
    struct TacoBell has key {
        id: UID, 
        price: u64, 
        balance: Balance<SUI>
    }  

    // Gotta init if ya gonna feast 
    fun init(ctx: &mut TxContext) {
        transfer::transfer(ShopOwnerCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx)); 

        // Open shop! 
        transfer::share_object(TacoBell {
            id: object::new(ctx), 
            price: 3, 
            balance: balance::zero()
        })
    }

    // Entry available to all that own tacos
    public fun buy_taco(
        shop: &mut TacoBell, payment: &mut Coin<SUI>, ctx: &mut TxContext 
    ) {
        assert!(coin::value(payment) >= shop.price, ENotEnough); 

        let coin_balance = coin::balance_mut(payment); 
        let paid = balance::split(coin_balance, shop.price)

        balance::join(&mut shop.balance, paid); 

        transfer::transfer(Taco {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    // Eat taco, only get fat
    public fun eat_taco(t: Taco) {
        let Taco { id } = t; 
        object::delete(id); 
    }

    // Transfer taco from Taco Bell 
    public fun collect_profits(
        _: &ShopOwnerCap, shop: &mut TacoBell, ctx: &mut TxContext
    ): Coin<SUI> {
        let amount = balance::value(&shop.balance); 
        coin::take(&mut shop.balance, amount, ctx)
    }

}