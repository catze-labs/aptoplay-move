
module aptoplay_minter::create_nft {
    use std::string;
    use std::vector;


    use std::signer;
    use std::string::String;
    use aptos_token::token::{Self,TokenDataId};
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::account::SignerCapability;
    use aptos_framework::resource_account;
    use aptos_framework::account;
    
    struct TokenMintingEvent has drop, store {
        token_reciever_address: address,
        token_data_id: TokenDataId,
    }

    // This struct stores an NFT collection's relevant information
    struct ModuleData has key {
        // Storing the signer capability here, so the module can programmatically sign for transactions
        signer_cap: SignerCapability,
        token_data_id: TokenDataId,
        token_minting_events: EventHandle<TokenMintingEvent>,
    }

    fun init_module(resource_signer: &signer) {
        let collection_name = string::utf8(b"Aptoplay-seccond");
        let description = string::utf8(b"https://aptoplay-web.vercel.app/");
        let collection_uri = string::utf8(b"Aptoplay, Effortless Integration, Seamless Experience in Aptos gaming solutions for game builders");
        let token_name = string::utf8(b"Aptoplay-pet");
        let token_uri = string::utf8(b"https://arweave.net/R-j5K_3jI6fiZcVUpkIB2rFfrFOqSE7eg_n0aWE7xak");

        let maximum_supply = 0;

        // Description, Uri, Maximum
        let mutate_setting = vector<bool>[ false, false, false ];


        token::create_collection(resource_signer, collection_name, description, collection_uri, maximum_supply, mutate_setting);


        let token_data_id = token::create_tokendata(
            resource_signer,
            collection_name,
            token_name,
            string::utf8(b""),
            0,
            token_uri,
            signer::address_of(resource_signer),
            1,
            0,
            // mutation for token maximum, uri, royalty, description, and properties.
            token::create_token_mutability_config(
                &vector<bool>[ false, true, false, true, true ]
            ),

            vector<String>[string::utf8(b"given_to")],
            vector<vector<u8>>[b""],
            vector<String>[ string::utf8(b"address") ],
        );

        
        let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, @source_addr);

        
        move_to(resource_signer, ModuleData {
            signer_cap: resource_signer_cap,
            token_data_id,
            token_minting_events: account::new_event_handle<TokenMintingEvent>(resource_signer)
        });
    }


    public entry fun mint_simple_pet(receiver: &signer) acquires ModuleData {
        let reciever_addr  = signer::address_of(receiver);
        let module_data = borrow_global_mut<ModuleData>(@aptoplay_minter);

        let resource_signer = account::create_signer_with_capability(&module_data.signer_cap);
        let token_id = token::mint_token(&resource_signer, module_data.token_data_id, 1);
        token::direct_transfer(&resource_signer, receiver, token_id, 1);

        event::emit_event<TokenMintingEvent>(
            &mut module_data.token_minting_events,
            TokenMintingEvent{
                token_reciever_address: reciever_addr,
                token_data_id: module_data.token_data_id,
            }
        );

        let (creator_address, collection, name) = token::get_token_data_id_fields(&module_data.token_data_id);
        token::mutate_token_properties(
            &resource_signer,
            reciever_addr,
            creator_address,
            collection,
            name,
            0,
            1,
            vector::empty<String>(),
            vector::empty<vector<u8>>(),
            vector::empty<String>(),
        );
    }
}
