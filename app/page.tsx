'use client';
import {
  DynamicContextProvider,
  DynamicWidget
} from "@dynamic-labs/sdk-react-core";
import { EthereumWalletConnectors } from "@dynamic-labs/ethereum";
import { useDynamicContext } from "@dynamic-labs/sdk-react-core";
import { useEffect } from "react";

const evmNetworks = [
  {
    blockExplorerUrls: ['https://sepolia.basescan.org/'],
    chainId: 84532,
    name: 'Base Sepolia',
    iconUrls: ['https://app.dynamic.xyz/assets/networks/base.svg'],
    nativeCurrency: { decimals: 18, name: 'Ether', symbol: 'ETH' },
    networkId: 84532,
    rpcUrls: ['https://sepolia.base.org'],
    vanityName: 'Base Sepolia',
  },
];

export default function Home() {
  return (
    <DynamicContextProvider
      settings={{
        environmentId: process.env.NEXT_PUBLIC_DYNAMIC_ENVIRONMENT_ID ?? "",
        overrides: { evmNetworks },
        walletConnectors: [EthereumWalletConnectors],
        authMode: "connect-only",
      }}
    >
      <HomeContent />
    </DynamicContextProvider>
  );
}

function HomeContent() {
  const { user, primaryWallet, awaitingSignatureState} = useDynamicContext();
  
  useEffect(() => {
    console.log('Dynamic Auth State:', {
      user,
      primaryWallet,
      awaitingSignatureState
    });
  }, [user, primaryWallet, awaitingSignatureState]);

  return (
    <div>
      <DynamicWidget />
    </div>
  );
}
