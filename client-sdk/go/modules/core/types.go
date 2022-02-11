package core

import (
	"github.com/oasisprotocol/oasis-sdk/client-sdk/go/types"
)

// EstimateGasQuery is the body of the core.EstimateGas query.
type EstimateGasQuery struct {
	// Caller is the address of the caller for which to do estimation. If not specified the
	// authentication information from the passed transaction is used.
	Caller *types.CallerAddress `json:"caller,omitempty"`
	// Tx is the unsigned transaction to estimate.
	Tx *types.Transaction `json:"tx"`
}

type RuntimeInfoResponse struct {
	ModuleVersion uint32 `json:"module_version"`
}
