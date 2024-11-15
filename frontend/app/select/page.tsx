'use client';

import { motion } from 'framer-motion';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import React from 'react';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useDynamicContext } from '@dynamic-labs/sdk-react-core';
import { encodePacked } from 'viem';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import data from '@/public/data.json';
import { keccak256, toBytes } from 'viem/utils';
import { verifyMessage } from 'viem';

export default function SelectPage() {
  const { primaryWallet, setShowAuthFlow, networkConfigurations } =
    useDynamicContext();
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [isInitialized, setIsInitialized] = useState(false);
  const [dappsId, setDappsId] = useState('');
  const [inviterAddress, setInviterAddress] = useState('');
  const router = useRouter();

  const handleSign = async () => {
    try {
      if (!dappsId) {
        toast.error('Please Enter Dapps ID');
        return;
      }

      console.log(
        'networkConfigurations?.evm?.[0]?.chainId',
        networkConfigurations?.evm?.[0]?.chainId
      );

      const chainSelectorId = getChainSelectorIdByChainId(
        (networkConfigurations?.evm?.[0]?.chainId || '').toString()
      );
      if (!chainSelectorId) {
        toast.error('Chain selector ID not found');
        return;
      }

      console.log('chainSelectorId', chainSelectorId);

      const message = encodePacked(
        ['uint256', 'uint64'],
        [BigInt(dappsId), BigInt(chainSelectorId)]
      );

      console.log('dappsId', dappsId);
      console.log('chainSelectorId', chainSelectorId);
      console.log('message', message);

      const messageHash = keccak256(toBytes(message));
      console.log('messageHash', messageHash);

      const signature = await primaryWallet?.signMessage(messageHash);
      console.log('signature:', signature);

       // viemを使用した署名の検証
    if (signature) {
      const isValid = await verifyMessage({
        address: primaryWallet.address,
        message: messageHash,
        signature: signature,
      });

      console.log('Signature verification result:', isValid);
      console.log('Signer address:', primaryWallet.address);

      if (isValid) {
        toast.success('署名が正しく検証されました');
      } else {
        toast.error('署名の検証に失敗しました');
      }
    }
    } catch (error) {
      toast.error(`signMessage error: ${error instanceof Error ? error.message : String(error)}`);
    }
  };

  useEffect(() => {
    // check connected wallet info when loading the page
    const checkConnection = async () => {
      const isConnected = localStorage.getItem('isConnected') === 'true';
      if (isConnected && !primaryWallet) {
        setShowAuthFlow(true);
      }
      setIsInitialized(true);
    };

    checkConnection();

    if (!primaryWallet) {
      router.push('/');
    }
  }, []);

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
        {selectedOption === 'inviter' ? (
          // inviter form
          <>
            <h2 className="text-xl font-bold text-white mb-4">
              Enter Required Information
            </h2>
            <Input
              placeholder="dapps_id"
              className="bg-white/10 border-white/20 text-white"
              value={dappsId}
              onChange={(e) => setDappsId(e.target.value)}
            />
            <Button
              onClick={handleSign}
              className="w-full bg-gradient-to-r from-yellow-500 to-orange-500 text-white p-6 rounded-xl text-lg"
            >
              Sign Message
            </Button>
          </>
        ) : (
          // invitee form
          <>
            <h2 className="text-xl font-bold text-white mb-4">
              Enter Required Information
            </h2>
            <Input
              placeholder="dapps_id"
              className="bg-white/10 border-white/20 text-white"
            />
            <Input
              placeholder="inviter_address"
              className="bg-white/10 border-white/20 text-white"
            />
          </>
        )}
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
            </div>
          )}

          {renderForm()}
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
