use std::collections::BTreeMap;

use crate::{
    keymanager::SignedPublicKey,
    types::transaction::{CallerAddress, Transaction},
};

/// Key in the versions map used for the global state version.
pub const VERSION_GLOBAL_KEY: &str = "";

/// Basic per-module metadata; tracked in core module's state.
#[derive(Clone, Debug, Default, cbor::Encode, cbor::Decode)]
pub struct Metadata {
    /// A set of state versions for all supported modules.
    pub versions: BTreeMap<String, u32>,
}

/// Arguments for the EstimateGas query.
#[derive(Clone, Debug, cbor::Encode, cbor::Decode)]
pub struct EstimateGasQuery {
    /// The address of the caller for which to do estimation. If not specified the authentication
    /// information from the passed transaction is used.
    #[cbor(optional)]
    pub caller: Option<CallerAddress>,
    /// The unsigned transaction to estimate.
    pub tx: Transaction,
}

/// Response to the call data public key query.
#[derive(Clone, Debug, cbor::Encode, cbor::Decode)]
pub struct CallDataPublicKeyQueryResponse {
    /// Public key used for deriving the shared secret for encrypting call data.
    pub public_key: SignedPublicKey,
}

#[derive(Debug, Copy, Clone, cbor::Encode, cbor::Decode)]
#[cfg_attr(test, derive(PartialEq, Eq))]
pub enum MethodHandlerKind {
    Call,
    // `Prefetch` is omitted because it is an implementation detail of handling `Call`s.
    Query,
    MessageResult,
}

#[derive(Debug, Clone, cbor::Encode, cbor::Decode)]
#[cfg_attr(test, derive(PartialEq, Eq))]
pub struct MethodHandlerInfo {
    pub kind: MethodHandlerKind,
    pub name: String,
}

/// Metadata for an individual module.
#[derive(Clone, Debug, cbor::Encode, cbor::Decode)]
#[cfg_attr(test, derive(PartialEq, Eq))]
pub struct ModuleInfo {
    pub version: u32,
    pub params: Vec<u8>,
    pub methods: Option<Vec<MethodHandlerInfo>>,
}

/// Response to the RuntimeInfo query.
#[derive(Clone, Debug, cbor::Encode, cbor::Decode)]
#[cfg_attr(test, derive(PartialEq, Eq))]
pub struct RuntimeInfoResponse {
    pub runtime_version: oasis_core_runtime::common::version::Version,
    pub state_version: u32,
    pub modules: BTreeMap<String, ModuleInfo>,
}
