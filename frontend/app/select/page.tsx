'use client';

import { motion } from 'framer-motion';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import React from 'react';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { createWalletClient, encodePacked, keccak256, http } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import data from '@/public/data.json';
import { useAccount, useSignMessage, useChainId, useDisconnect } from 'wagmi';
import { baseSepolia } from 'viem/chains';
import HCaptcha from '@hcaptcha/react-hcaptcha';

export default function SelectPage() {
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [dappsId, setDappsId] = useState('');
  const [inviterAddress, setInviterAddress] = useState('');
  const router = useRouter();
  const { signMessageAsync } = useSignMessage();
  const chainId = useChainId();
  const { address, isConnected } = useAccount();
  const [hcaptchaToken, setHcaptchaToken] = useState<string | null>(null);
  const { disconnect } = useDisconnect();

  useEffect(() => {
    if (!hcaptchaToken) {
      console.error("hCaptcha token is not available. Retrying...");

      const timeout = setTimeout(() => {
        if (!hcaptchaToken) {
          console.error("hCaptcha token is still not available.");
        } else {
          console.log("hCaptcha token is now available.");
        }
      }, 3000);
  
      return () => clearTimeout(timeout);
    } else {
      console.log('hcaptchaToken:', hcaptchaToken);
      console.log("hCaptcha token is available.");
    }
  }, [hcaptchaToken]);

  
  const handleInviterSubmit  = async (event: React.FormEvent) => {
    event.preventDefault();

    try {
      // Existing signature logic
      if (!isConnected) {
        toast.error('Please connect your wallet');
        return;
      }

      if (!dappsId) {
        toast.error('Please Enter Dapps ID');
        return;
      }

      const chainSelectorId = getChainSelectorIdByChainId(chainId.toString());

      console.log('chainSelectorId:', chainSelectorId);
      console.log('address:', address);

      console.log('chainId:', chainId);
      
      if (!chainSelectorId) {
        toast.error('Chain selector ID not found');
        return;
      }

      // Create packed message
      const packedMessage = encodePacked(
        ['uint256', 'uint64'],
        [BigInt(dappsId), BigInt(chainSelectorId)]
      );

      // Create message hash for ECDSA signature
      const messageHash = keccak256(packedMessage);
      

      // Generate ECDSA signature
      const signature = await signMessageAsync({
        account: address, 
        message: { raw: messageHash }
      });

      console.log('signature:', signature);

      console.log('ECDSA signature:', signature);
      toast.success('ECDSA signature generated successfully');
      
    } catch (error) {
      toast.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    }
  };

  const handleInviteeSubmit  = async (event: React.FormEvent) => {
    event.preventDefault();

    try {
      if (!hcaptchaToken) {
        console.error('hCaptcha token is not available');
        toast.error('hCaptcha is not ready');
        return;
      }

      // Verify hCaptcha token
      const verificationResponse = await fetch('/api/hcaptcha', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ token: hcaptchaToken }),
      });

      console.log(verificationResponse);

      if (!verificationResponse.ok) {
        toast.error('hCaptcha verification failed');
        return;
      }

      // Existing signature logic
      if (!isConnected) {
        toast.error('Please connect your wallet');
        return;
      }

      if (!dappsId) {
        toast.error('Please Enter Dapps ID');
        return;
      }

      // Create packed message
      const packedMessage = encodePacked(
        ['address', 'uint256'],
        [address as `0x${string}`, BigInt(dappsId)]
      );

      // Create message hash for ECDSA signature
      const messageHash = keccak256(packedMessage);

      console.log('messageHash:', messageHash);

      console.log('process.env.WALLET_PRIVATE_KEY:', process.env.NEXT_PUBLIC_WALLET_PRIVATE_KEY);

      const account = privateKeyToAccount(process.env.NEXT_PUBLIC_WALLET_PRIVATE_KEY as `0x${string}`);

      console.log('account:', account);

      const signature = await signMessageAsync({
        account: account,
        message: { raw: messageHash }
      });

      console.log('signature:', signature);

      console.log('ECDSA signature:', signature);
      toast.success('ECDSA signature generated successfully');
      
    } catch (error) {
      toast.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    }
  };


  useEffect(() => {
    console.log(address);
    if (!address) {
      router.push('/');
    }
  }, [address]);

  const handleSelect = (option: string) => {
    setSelectedOption(option);
    setTimeout(() => {
      setShowForm(true);
    }, 100);
  };

  const renderForm = () => {
    if (!showForm) return null;

    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mt-8 space-y-4"
      >
        {!isConnected ? (
          <></>
        ) : selectedOption === 'inviter' ? (
          // inviter form
          <form onSubmit={handleInviterSubmit} className="space-y-4">
            <h2 className="text-xl font-bold text-white mb-4">
              Enter Required Information
            </h2>
            <Input
              placeholder="dapps_id"
              className="bg-white/10 border-white/20 text-white"
              value={dappsId}
              onChange={(e) => setDappsId(e.target.value)}
              required
            />
            <Button
              type="submit"
              className="w-full bg-gradient-to-r from-yellow-500 to-orange-500 text-white p-6 rounded-xl text-lg"
            >
              Sign Message
            </Button>
          </form>
        ) : selectedOption === 'invitee' ? (
          // invitee form
          <form onSubmit={handleInviteeSubmit} className="space-y-4">
            <h2 className="text-xl font-bold text-white mb-4">
              Enter Required Information
            </h2>
            <Input
              placeholder="dapps_id"
              className="bg-white/10 border-white/20 text-white"
              value={dappsId}
              onChange={(e) => setDappsId(e.target.value)}
              required
            />
            <Input
              placeholder="inviter_address"
              className="bg-white/10 border-white/20 text-white"
              value={inviterAddress}
              onChange={(e) => setInviterAddress(e.target.value)}
              required
            />
            <div className="flex justify-center">
              <HCaptcha
                sitekey={process.env.NEXT_PUBLIC_HCAPTCHA_SITE_KEY}
                onVerify={(token) => setHcaptchaToken(token)}
                theme="dark"
                size="compact"
              />
            </div>
            <Button
              type="submit"
              className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white p-6 rounded-xl text-lg"
            >
              Sign Message
            </Button>
          </form>
        ) : selectedOption === 'dapps' ? (
          // dapps form
          <form onSubmit={handleDappsSubmit} className="space-y-4">
            <h2 className="text-xl font-bold text-white mb-4">
              Enter Dapps Information
            </h2>
            <Input
              placeholder="dapps_id"
              className="bg-white/10 border-white/20 text-white"
              value={dappsId}
              onChange={(e) => setDappsId(e.target.value)}
              required
            />
            <Button
              type="submit"
              className="w-full bg-gradient-to-r from-green-500 to-teal-500 text-white p-6 rounded-xl text-lg"
            >
              Submit Dapps
            </Button>
          </form>
        ) : null}
      </motion.div>
    );
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-black p-4">
      <ToastContainer
        position="top-right"
        autoClose={3000}
        hideProgressBar={false}
        closeOnClick
        pauseOnHover
        theme="dark"
      />
      <motion.div
        className="w-full max-w-md"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="bg-white/10 backdrop-blur-3xl rounded-3xl shadow-2xl border border-white/20 p-8 space-y-6">
          <h1 className="text-3xl font-bold text-center text-white mb-8">
            {!selectedOption
              ? 'Choose Your Role'
              : 'You have selected ' + selectedOption}
          </h1>

          {!selectedOption && (
            <div className="space-y-4">
              <motion.div whileHover={{ scale: 1.02 }}>
                <Button
                  className="w-full bg-gradient-to-r from-purple-500 to-pink-500 text-white p-6 rounded-xl text-lg"
                  onClick={() => handleSelect('inviter')}
                >
                  Inviter
                </Button>
              </motion.div>

              <motion.div whileHover={{ scale: 1.02 }}>
                <Button
                  className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white p-6 rounded-xl text-lg"
                  onClick={() => handleSelect('invitee')}
                >
                  Invitee
                </Button>
              </motion.div>

              <motion.div whileHover={{ scale: 1.02 }}>
                <Button
                  className="w-full bg-gradient-to-r from-green-500 to-teal-500 text-white p-6 rounded-xl text-lg"
                  onClick={() => handleSelect('dapps')}
                >
                  Dapps
                </Button>
              </motion.div>
            </div>
          )}

          {renderForm()}

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
  );
}

export const getChainSelectorIdByChainId = (
  chainId: string
): bigint | undefined => {
  const chainData = data.find((item) => item.chainId === parseInt(chainId));
  console.log('chainData', chainData);
  return chainData ? BigInt(chainData.chainSelectorId) : undefined;
};
