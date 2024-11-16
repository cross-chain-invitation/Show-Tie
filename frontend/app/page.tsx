'use client';

import { motion } from 'framer-motion';
import { Button } from '@/components/ui/button';
import { disconnect } from '@wagmi/core';
import React from 'react';
import { useRouter } from 'next/navigation';
import {
  ConnectWallet,
  Wallet
} from '@coinbase/onchainkit/wallet';
import {
  Name
} from '@coinbase/onchainkit/identity';
import { useState, useEffect } from 'react';
import { useAccount } from 'wagmi';
import { useDisconnect } from 'wagmi'
import { useConnect } from 'wagmi';
import { Select } from '@/components/ui/select';
import { useChainId } from 'wagmi';
import { useSwitchChain } from 'wagmi'

interface BackgroundElement {
  left: string;
  top: string;
  width: string;
  height: string;
}

export default function Home() {
  const router = useRouter();
  const [backgroundElements, setBackgroundElements] = useState<BackgroundElement[]>([]);
  const [hue, setHue] = useState(0);
  const { address } = useAccount();
  const { disconnect } = useDisconnect();
  const chainId = useChainId();
  const { chains, switchChain } = useSwitchChain()


  useEffect(() => {
    console.log(address);
    console.log(chainId);

    if (address) {
      router.push('/select');
    }
  }, [address, chainId]);

  useEffect(() => {
    setHue(0);
    const interval = setInterval(() => {
      setHue((prevHue) => (prevHue + 1) % 360);
    }, 50);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const elements = Array.from({ length: 20 }).map((_, i) => ({
      left: `${(i * 5) % 100}%`,
      top: `${(i * 7) % 100}%`,
      width: `${150 + i * 10}px`,
      height: `${150 + i * 10}px`,
    }));
    setBackgroundElements(elements);
  }, []);

  return (
    <div>
      <div className="min-h-screen flex items-center justify-center overflow-hidden bg-black p-4">
        <div className="absolute inset-0 overflow-hidden">
          {backgroundElements.map((pos, i) => (
            <motion.div
              key={i}
              className="absolute rounded-full mix-blend-screen filter blur-xl opacity-30"
              animate={{
                scale: [1, 2, 2, 1, 1],
                x: [0, 200, 0, -200, 0],
                y: [0, -200, 200, 0, 0],
                backgroundColor: [
                  `hsl(${hue}, 100%, 50%)`,
                  `hsl(${(hue + 60) % 360}, 100%, 50%)`,
                  `hsl(${(hue + 120) % 360}, 100%, 50%)`,
                  `hsl(${(hue + 180) % 360}, 100%, 50%)`,
                  `hsl(${hue}, 100%, 50%)`,
                ],
              }}
              transition={{
                duration: 10,
                repeat: Infinity,
                repeatType: 'reverse',
              }}
              style={{
                left: pos.left,
                top: pos.top,
                width: pos.width,
                height: pos.height,
              }}
            />
          ))}
        </div>
        <motion.div
          className="relative z-10 w-full max-w-md"
          initial={{ rotateY: 180, opacity: 0 }}
          animate={{ rotateY: 0, opacity: 1 }}
          transition={{ duration: 1.5, type: 'spring' }}
        >
          <div className="bg-white/10 backdrop-blur-3xl rounded-3xl shadow-2xl overflow-hidden border border-white/20 p-8 space-y-8">
            <motion.h1
              className="text-4xl font-extrabold text-center text-white"
              animate={{
                textShadow: [
                  '0 0 10px #fff',
                  '0 0 20px #fff',
                  '0 0 30px #fff',
                  '0 0 40px #0ff',
                  '0 0 70px #0ff',
                  '0 0 80px #0ff',
                  '0 0 100px #0ff',
                  '0 0 150px #0ff',
                ],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                repeatType: 'reverse',
              }}
            >
              Show-Tie
            </motion.h1>
            
            <Wallet>
              {!address && (
                <ConnectWallet 
                  onConnect={() => router.push('/select')}
                  className="w-full bg-gradient-to-r from-purple-500 via-pink-500 to-red-500 text-white font-bold py-4 rounded-full text-lg relative overflow-hidden group text-center flex justify-center"
                >
                  Connect Wallet
                </ConnectWallet>
              )}
            </Wallet>

            <div className="flex space-x-4">
              {chains.map((chain) => (
                <button 
                  key={chain.id} 
                  onClick={() => switchChain({ chainId: chain.id })}
                  className="px-4 py-2 bg-blue-500 text-white font-semibold rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75"
                >
                  {chain.name}
                </button>
              ))}
            </div>
            
            {address && (
              <Button 
                onClick={() => disconnect()}
                className="w-full bg-gradient-to-r from-purple-500 via-pink-500 to-red-500 text-white font-bold py-4 rounded-full text-lg relative overflow-hidden group text-center flex justify-center"
              >
                Logout
              </Button>
            )}
          </div>
        </motion.div>
      </div>
    </div>
  );
}
