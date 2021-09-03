//! Simple EVM runtime.
use std::collections::BTreeMap;

use oasis_runtime_sdk::{self as sdk, modules, types::token::Denomination, Version};
use oasis_runtime_sdk_evm as evm;

/// Simple EVM runtime.
pub struct Runtime;

/// Configuration for the EVM module.
pub struct EVMConfig;

impl evm::Config for EVMConfig {
    type Accounts = modules::accounts::Module;
}

impl sdk::Runtime for Runtime {
    const VERSION: Version = sdk::version_from_cargo!();

    type Modules = (
        modules::accounts::Module,
        modules::core::Module,
        evm::Module<EVMConfig>,
    );

    fn genesis_state() -> <Self::Modules as sdk::module::MigrationHandler>::Genesis {
        (
            modules::accounts::Genesis {
                parameters: Default::default(),
                balances: {
                    let mut b = BTreeMap::new();
                    // Alice.
                    b.insert(sdk::testing::keys::alice::address(), {
                        let mut d = BTreeMap::new();
                        d.insert(Denomination::NATIVE, 10_000_000);
                        d
                    });
                    // Dave.
                    b.insert(sdk::testing::keys::dave::address(), {
                        let mut d = BTreeMap::new();
                        d.insert(Denomination::NATIVE, 100_000_000);
                        d
                    });
                    b
                },
                total_supplies: {
                    let mut ts = BTreeMap::new();
                    ts.insert(Denomination::NATIVE, 110_000_000);
                    ts
                },
                ..Default::default()
            },
            modules::core::Genesis {
                parameters: modules::core::Parameters {
                    max_batch_gas: 1_000_000,
                    max_tx_signers: 8,
                    max_multisig_signers: 8,
                    gas_costs: modules::core::GasCosts {
                        auth_signature: 0,
                        auth_multisig_signer: 0,
                        ..Default::default()
                    },
                },
            },
            evm::Genesis {
                parameters: evm::Parameters {
                    min_gas_price: Default::default(),
                    token_denomination: Denomination::NATIVE,
                    gas_costs: evm::GasCosts {
                        tx_deposit: 10,
                        tx_withdraw: 20,
                    },
                },
            },
        )
    }
}
