'use client';

import { WagmiProvider, createConfig, http } from 'wagmi';
import { baseSepolia, sepolia } from 'wagmi/chains';
import { coinbaseWallet } from 'wagmi/connectors';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { metaMask } from '@wagmi/connectors';

const wagmiConfig = createConfig({
  chains: [baseSepolia, sepolia],
  connectors: [
    metaMask(),
    coinbaseWallet({
      appName: 'onchainkit',
    }),
  ],
  ssr: true,
  transports: {
    [baseSepolia.id]: http(),
    [sepolia.id]: http(),
  },
});

const queryClient = new QueryClient();

export default function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <WagmiProvider config={wagmiConfig}>
        {children}
      </WagmiProvider>
    </QueryClientProvider>
  );
}