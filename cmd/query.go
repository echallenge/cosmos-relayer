package cmd

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/cosmos/cosmos-sdk/client/flags"
	"github.com/cosmos/cosmos-sdk/x/auth"
	tmclient "github.com/cosmos/cosmos-sdk/x/ibc/07-tendermint/types"
	"github.com/cosmos/relayer/relayer"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

func init() {
	queryCmd.AddCommand(queryAccountCmd())
	queryCmd.AddCommand(queryBalanceCmd())
	queryCmd.AddCommand(queryHeaderCmd())
	queryCmd.AddCommand(queryNodeStateCmd())
	queryCmd.AddCommand(queryClientCmd())
	queryCmd.AddCommand(queryClientsCmd())
	queryCmd.AddCommand(queryConnection())
	queryCmd.AddCommand(queryConnections())
	queryCmd.AddCommand(queryConnectionsUsingClient())
	queryCmd.AddCommand(queryChannel())
	queryCmd.AddCommand(queryChannels())
	queryCmd.AddCommand(queryNextSeqRecv())
	queryCmd.AddCommand(queryPacketCommitment())
	queryCmd.AddCommand(queryPacketAck())
	queryCmd.AddCommand(queryTxs())
	queryCmd.AddCommand(queryTx())
	queryCmd.AddCommand(queryQueue())
}

// queryCmd represents the chain command
var queryCmd = &cobra.Command{
	Use:     "query",
	Aliases: []string{"q"},
	Short:   "query functionality for configured chains",
}

func queryTx() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "tx [chain-id] [tx-hash]",
		Short: "Query transaction by transaction hash",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			txs, err := chain.QueryTx(args[1])
			if err != nil {
				return err
			}

			return queryOutput(txs, chain, cmd)
		},
	}
	return cmd
}

func queryTxs() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "txs [chain-id] [events]",
		Short: "Query transactions by the events they produce",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			events, err := relayer.ParseEvents(args[1])
			if err != nil {
				return err
			}

			h, err := chain.UpdateLiteWithHeader()
			if err != nil {
				return err
			}

			txs, err := chain.QueryTxs(h.GetHeight(), viper.GetInt(flags.FlagPage), viper.GetInt(flags.FlagLimit), events)
			if err != nil {
				return err
			}

			return queryOutput(txs, chain, cmd)
		},
	}
	return paginationFlags(cmd)
}

func queryAccountCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "account [chain-id]",
		Aliases: []string{"acc"},
		Short:   "Query the account data of the relayer account",
		Args:    cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			addr, err := chain.GetAddress()
			if err != nil {
				return err
			}

			acc, err := auth.NewAccountRetriever(chain.Cdc, chain).GetAccount(addr)
			if err != nil {
				return err
			}

			return queryOutput(acc, chain, cmd)
		},
	}
	return cmd
}

func queryBalanceCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "balance [chain-id] [[key-name]]",
		Aliases: []string{"bal"},
		Short:   "Query the account balance of the relayer account, or pass in an optional second arg to fetch balance from a configured key",
		Args:    cobra.RangeArgs(1, 2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			jsn, err := cmd.Flags().GetBool(flagJSON)
			if err != nil {
				return err
			}

			var keyName string
			if len(args) == 2 {
				keyName = args[1]
			}

			coins, err := chain.QueryBalance(keyName)
			if err != nil {
				return err
			}

			var out string
			if jsn {
				byt, err := json.Marshal(coins)
				if err != nil {
					return err
				}
				out = string(byt)
			} else {
				out = coins.String()
			}

			fmt.Println(out)
			return nil
		},
	}
	return jsonFlag(cmd)
}

func queryHeaderCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "header [chain-id] [height]",
		Aliases: []string{"hdr"},
		Short:   "Query the header at a given height",
		Args:    cobra.RangeArgs(1, 2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			var header *tmclient.Header

			switch len(args) {
			case 1:
				header, err = chain.QueryLatestHeader()
				if err != nil {
					return err
				}
			case 2:
				var height int64
				height, err = strconv.ParseInt(args[1], 10, 64) //convert to int64
				if err != nil {
					return err
				}

				if height == 0 {
					height, err = chain.QueryLatestHeight()
					if err != nil {
						return err
					}

					if height == -1 {
						return relayer.ErrLiteNotInitialized
					}
				}

				header, err = chain.QueryHeaderAtHeight(height)
				if err != nil {
					return err
				}

			}

			if viper.GetBool(flagFlags) {
				fmt.Printf("-x %x --height %d", header.SignedHeader.Hash(), header.Header.Height)
				return nil
			}

			return queryOutput(header, chain, cmd)
		},
	}

	return flagsFlag(cmd)
}

// GetCmdQueryConsensusState defines the command to query the consensus state of
// the chain as defined in https://github.com/cosmos/ics/tree/master/spec/ics-002-client-semantics#query
func queryNodeStateCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "node-state [chain-id] [height]",
		Short: "Query the consensus state of a client at a given height, or at latest height if height is not passed",
		Args:  cobra.RangeArgs(1, 2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			var height int64
			switch len(args) {
			case 1:
				height, err = chain.QueryLatestHeight()
				if err != nil {
					return err
				}
			case 2:
				height, err = strconv.ParseInt(args[1], 10, 64)
				if err != nil {
					fmt.Println("invalid height, defaulting to latest:", args[1])
					height = 0
				}
			}

			csRes, err := chain.QueryConsensusState(height)
			if err != nil {
				return err
			}

			return queryOutput(csRes, chain, cmd)
		},
	}

	return cmd
}

func queryClientCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "client [chain-id] [client-id]",
		Aliases: []string{"clnt"},
		Short:   "Query the client state for the given client id",
		Args:    cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			if err = chain.AddPath(args[1], dcon, dcha, dpor); err != nil {
				return err
			}

			res, err := chain.QueryClientState()
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return cmd
}

func queryClientsCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "clients [chain-id]",
		Aliases: []string{"clnts"},
		Short:   "Query for all client states",
		Args:    cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			res, err := chain.QueryClients(viper.GetInt(flags.FlagPage), viper.GetInt(flags.FlagLimit))
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryConnections() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "connections [chain-id]",
		Aliases: []string{"conns"},
		Short:   "Query for all connections",
		Args:    cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			res, err := chain.QueryConnections(viper.GetInt(flags.FlagPage), viper.GetInt(flags.FlagLimit))
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryConnectionsUsingClient() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "client-connections [chain-id] [client-id]",
		Aliases: []string{"clnt-conns"},
		Short:   "Query for all connections on a given client",
		Args:    cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			if err := chain.AddPath(args[1], dcon, dcha, dpor); err != nil {
				return err
			}

			height, err := chain.QueryLatestHeight()
			if err != nil {
				return err
			}

			res, err := chain.QueryConnectionsUsingClient(height)
			if err != nil {
				return err
			}

			return queryOutput(res.ConnectionPaths, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryConnection() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "connection [chain-id] [connection-id]",
		Aliases: []string{"conn"},
		Short:   "Query the connection state for the given connection id",
		Args:    cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			if err := chain.AddPath(dcli, args[1], dcon, dpor); err != nil {
				return err
			}

			height, err := chain.QueryLatestHeight()
			if err != nil {
				return err
			}

			res, err := chain.QueryConnection(height)
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryChannel() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "channel [chain-id] [channel-id] [port-id]",
		Aliases: []string{"chan"},
		Short:   "Query the channel for the given channel and port ids",
		Args:    cobra.ExactArgs(3),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			if err = chain.AddPath(dcli, dcon, args[1], args[2]); err != nil {
				return err
			}

			height, err := chain.QueryLatestHeight()
			if err != nil {
				return err
			}

			res, err := chain.QueryChannel(height)
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryChannels() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "channels [chain-id]",
		Aliases: []string{"chans"},
		Short:   "Query for all channels",
		Args:    cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			res, err := chain.QueryChannels(viper.GetInt(flags.FlagPage), viper.GetInt(flags.FlagLimit))
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryNextSeqRecv() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "seq-send [chain-id] [channel-id] [port-id]",
		Short: "Query the next sequence send for a given channel",
		Args:  cobra.ExactArgs(3),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			if err = chain.AddPath(dcli, dcon, args[1], args[2]); err != nil {
				return err
			}

			height, err := chain.QueryLatestHeight()
			if err != nil {
				return err
			}

			res, err := chain.QueryNextSeqRecv(height)
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryPacketCommitment() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "packet-commit [chain-id] [channel-id] [port-id] [seq]",
		Short: "Query the commitment for a given packet",
		Args:  cobra.ExactArgs(4),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			if err = chain.AddPath(dcli, dcon, args[1], args[2]); err != nil {
				return err
			}

			height, err := chain.QueryLatestHeight()
			if err != nil {
				return err
			}

			seq, err := strconv.ParseInt(args[3], 10, 64)
			if err != nil {
				return err
			}

			res, err := chain.QueryPacketCommitment(height, seq)
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryPacketAck() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "packet-ack [chain-id] [channel-id] [port-id] [seq]",
		Short: "Query the commitment for a given packet",
		Args:  cobra.ExactArgs(4),
		RunE: func(cmd *cobra.Command, args []string) error {
			chain, err := config.Chains.Get(args[0])
			if err != nil {
				return err
			}

			if err = chain.AddPath(dcli, dcon, args[1], args[2]); err != nil {
				return err
			}

			height, err := chain.QueryLatestHeight()
			if err != nil {
				return err
			}

			seq, err := strconv.ParseInt(args[3], 10, 64)
			if err != nil {
				return err
			}

			res, err := chain.QueryPacketAck(height, seq)
			if err != nil {
				return err
			}

			return queryOutput(res, chain, cmd)
		},
	}

	return paginationFlags(cmd)
}

func queryQueue() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "queue [path]",
		Short: "Query for the packets that remain to be relayed on a given path",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			path, err := config.Paths.Get(args[0])
			if err != nil {
				return err
			}
			src, dst := path.Src.ChainID, path.Dst.ChainID

			c, err := config.Chains.Gets(src, dst)
			if err != nil {
				return err
			}

			if err = c[src].SetPath(path.Src); err != nil {
				return err
			}
			if err = c[dst].SetPath(path.Dst); err != nil {
				return err
			}

			hs, err := relayer.UpdatesWithHeaders(c[src], c[dst])
			if err != nil {
				return err
			}

			sp, err := relayer.UnrelayedSequences(c[src], c[dst], hs[src].Height, hs[dst].Height)
			if err != nil {
				return err
			}

			return c[src].Print(sp, false, false)
		},
	}

	return cmd
}

func queryOutput(res interface{}, chain *relayer.Chain, cmd *cobra.Command) error {
	return chain.Print(res, false, false)
}
