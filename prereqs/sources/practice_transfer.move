module examples::wrapper {
    use sui::object::{Self, UID}; 
    use sui::tx_context::TxContext; 

    struct Wrapper<X: store> has key, store {
        id: UID, 
        contents: X
    }

    public fun contents<X: store>(c: &Wrapper<X>): &X {
        &c.contents
    }

    public fun create<X: store>(
        contents: X, ctx: &mut TxContext
    ): Wrapper<X> {
        Wrapper {
            contents, 
            id: object::new(ctx), 
        }
    }

    public fun destroy<X: store> (c:Wrapper<X>): X {
        let Wrapper { id, contents } = c; 
        object::delete(id); 
        contents 
    }
}

module examples::profile {
    use sui::url::{Self, Url}; 
    use std::string::{Self, String}; 
    use sui::tx_context::TxContext; 

    use examples::wrapper::{Self, Wrapper}; 

    struct ProfileInfo has store{
        name: String, 
        url: Url
    }

    public fun name(info &ProfileInfo): &String {
        &info.name
    }

    public fun url(info: &ProfileInfo): &Url {
        &info.url
    }

    public fun create_profile(
        name: vector<u8>, url: vector<u8>, ctx: &mut TxContext
    ): Wrapper<ProfileInfo> {
        let container = wrapper::create(ProfileInfo {
            name: string::utf8(name), 
            url: url::new_unsafe_from_bytes(url)
        }, ctx); 

        container
    }
}