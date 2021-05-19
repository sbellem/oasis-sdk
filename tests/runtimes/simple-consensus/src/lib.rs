//! Simple consensus runtime.
use oasis_runtime_sdk::{self as sdk, modules, Version};

/// Simple consensus runtime.
pub struct Runtime;

impl sdk::Runtime for Runtime {
    const VERSION: Version = sdk::version_from_cargo!();

    type Modules = (
        modules::accounts::Module,
        modules::consensus_accounts::Module<modules::accounts::Module, modules::consensus::Module>,
        modules::core::Module,
    );

    fn genesis_state() -> <Self::Modules as sdk::module::MigrationHandler>::Genesis {
        (
            Default::default(),
            modules::consensus_accounts::Genesis {
                parameters: modules::consensus_accounts::Parameters {
                    gas_costs: modules::consensus_accounts::GasCosts {
                        // These are free, in order to simplify testing. We do test gas accounting
                        // with other methods elsewhere though.
                        tx_deposit: 0,
                        tx_withdraw: 0,
                    },
                },
            },
            modules::core::Genesis {
                parameters: modules::core::Parameters {
                    max_batch_gas: 10_000,
                    max_tx_signers: 8,
                    max_multisig_signers: 8,
                },
            },
        )
    }
}
