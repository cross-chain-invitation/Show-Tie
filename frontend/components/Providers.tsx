'use client';

import { WagmiProvider, createConfig, http } from 'wagmi';
import { baseSepolia, sepolia, celoAlfajores, scrollSepolia } from 'wagmi/chains';
import { coinbaseWallet } from 'wagmi/connectors';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { metaMask } from '@wagmi/connectors';

export const wagmiConfig = createConfig({
  chains: [baseSepolia, sepolia, celoAlfajores, scrollSepolia],
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
    [celoAlfajores.id]: http(),
    [scrollSepolia.id]: http(),
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