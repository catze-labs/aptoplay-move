
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

    /// `init_module` is automatically called when publishing the module.
    /// In this function, we create an example NFT collection and an example token.
    fun init_module(resource_signer: &signer) {
        let collection_name = string::utf8(b"Aptoplay-seccond");
        let description = string::utf8(b"https://aptoplay-web.vercel.app/");
        let collection_uri = string::utf8(b"Aptoplay, Effortless Integration, Seamless Experience in Aptos gaming solutions for game builders");
        let token_name = string::utf8(b"Aptoplay-pet");
        let token_uri = string::utf8(b"https://arweave.net/R-j5K_3jI6fiZcVUpkIB2rFfrFOqSE7eg_n0aWE7xak");
        // This means that the supply of the token will not be tracked.
        let maximum_supply = 100;
        // This variable sets if we want to allow mutation for collection description, uri, and maximum.
        // Here, we are setting all of them to false, which means that we don't allow mutations to any CollectionData fields.
        let mutate_setting = vector<bool>[ false, false, false ];

        // Create the nft collection.
        token::create_collection(resource_signer, collection_name, description, collection_uri, maximum_supply, mutate_setting);

        // Create a token data id to specify the token to be minted.
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
            // This variable sets if we want to allow mutation for token maximum, uri, royalty, description, and properties.
            // Here we enable mutation for properties by setting the last boolean in the vector to true.
            token::create_token_mutability_config(
                &vector<bool>[ false, true, false, true, true ]
            ),
            // We can use property maps to record attributes related to the token.
            // In this example, we are using it to record the receiver's address.
            // We will mutate this field to record the user's address
            // when a user successfully mints a token in the `mint_event_ticket()` function.
            vector<String>[string::utf8(b"given_to")],
            vector<vector<u8>>[b""],
            vector<String>[ string::utf8(b"address") ],
        );

        // Retrieve the resource signer's signer capability and store it within the `ModuleData`.
        // Note that by calling `resource_account::retrieve_resource_account_cap` to retrieve the resource account's signer capability,
        // we rotate th resource account's authentication key to 0 and give up our control over the resource account. Before calling this function,
        // the resource account has the same authentication key as the source account so we had control over the resource account.
        let resource_signer_cap = resource_account::retrieve_resource_account_cap(resource_signer, @source_addr);

        // Store the token data id and the resource account's signer capability within the module, so we can programmatically
        // sign for transactions in the `mint_event_ticket()` function.
        move_to(resource_signer, ModuleData {
            signer_cap: resource_signer_cap,
            token_data_id,
            token_minting_events: account::new_event_handle<TokenMintingEvent>(resource_signer)
        });
    }

    /// Mint an NFT to the receiver. Note that different from the tutorial in part 1, here we only ask for the receiver's
    /// signer. This is because we used resource account to publish this module and stored the resource account's signer
    /// within the `ModuleData`, so we can programmatically sign for transactions instead of manually signing transactions.
    /// See https://aptos.dev/concepts/accounts/#resource-accounts for more information about resource account.
    public entry fun mint_event_ticket(receiver: &signer) acquires ModuleData {
        let reciever_addr  = signer::address_of(receiver);
        let module_data = borrow_global_mut<ModuleData>(@aptoplay_minter);

        // Create a signer of the resource account from the signer capabiity stored in this module.
        // Using a resource account and storing its signer capability within the module allows the module to programmatically
        // sign transactions on behalf of the module.
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
        // Mutate the token properties to update the property version of this token.
        // Note that here we are re-using the same token data id and only updating the property version.
        // This is because we are simply printing edition of the same token, instead of creating unique
        // tokens. The tokens created this way will have the same token data id, but different property versions.
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
