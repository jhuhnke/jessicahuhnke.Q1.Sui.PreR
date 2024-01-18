module examples::restricted_transfer {
    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::sui::SUI;

    const EWrongAmount: u64 = 0; 

    struct StomachCapability has key { id: UID }

    struct TacoBellFranchise has key {
        id: UID,
        contents: beefy5layers
    }

    /// A centralized registry that approves property ownership
    /// transfers and collects fees.
    struct CreditCard has key {
        id: UID,
        balance: Balance<SUI>,
        fee: u64
    }

    /// Create a `CreditCard` on module init.
    fun init(ctx: &mut TxContext) {
        transfer::transfer(StomachCapability {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::share_object(CreditCard {
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
            fee: 10000
        })
    }

    /// Create `TacoBellFranchise` and transfer it to the property owner.
    /// Only owner of the `StomachCapability` can perform this action.
    public fun issue_franchise(
        _: &StomachCapability,
        for: address,
        ctx: &mut TxContext
    ) {
        transfer::transfer(TacoBellFranchise {
            id: object::new(ctx)
        }, for)
    }

    /// A custom transfer function. Required due to `TacoBellFranchise` not having
    /// a `store` ability. All transfers of `TacoBellFranchise`s have to go through
    /// this function and pay a fee to the `CreditCard`.
    public fun transfer_ownership(
        registry: &mut CreditCard,
        paper: TacoBellFranchise,
        fee: Coin<SUI>,
        to: address,
    ) {
        assert!(coin::value(&fee) == registry.fee, EWrongAmount);

        // add a payment to the CreditCard balance
        balance::join(&mut registry.balance, coin::into_balance(fee));

        // finally call the transfer function
        transfer::transfer(paper, to)
    }
}