module examples::my_hero {
    use sui::tx_context::{sender, TxContext};
    use std::string::{utf8, String};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::package;
    use sui::display;

    /// The GS Teddy - an outstanding collection of digital art.
    struct Paris_Teddy has key, store {
        id: UID,
        name: String,
        img_url: String,
    }

    /// One-Time-Witness for the module.
    struct TEDDY has drop {}

    fun init(otw: TEDDY, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            utf8(b"{name}"),  
            utf8(b"https://teddydao.io/teddy/{id}"),
            // I'm not changing this because I don't have art rip
            utf8(b"ipfs://{img_url}"),
            // Description is static for all `Teddy` objects.
            utf8(b"Sui ecosystem's snuggliest!"),
            // Project URL is usually static
            utf8(b"https://teddydao.io"),
            // Creator field can be any
            utf8(b"a beefy 5 layer burrito")
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `Hero` type.
        let display = display::new_with_fields<Hero>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }

    /// Anyone can mint their `Teddy`!
    public fun mint(name: String, img_url: String, ctx: &mut TxContext): Teddy {
        let id = object::new(ctx);
        Teddy { id, name, img_url }
    }
}