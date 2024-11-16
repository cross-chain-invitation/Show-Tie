'use client';

import { motion } from 'framer-motion';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import React from 'react';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { encodePacked, keccak256, decodeAbiParameters } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import data from '@/public/data.json';
import { useAccount, useSignMessage, useChainId, useDisconnect, useSwitchChain } from 'wagmi';
import { writeContract } from '@wagmi/core';
import HCaptcha from '@hcaptcha/react-hcaptcha';
import ERC20ABI from '@/src/abi/ERC20.json';
import ShowtieABI from '@/src/abi/Showtie.json';
import { IndexService } from "@ethsign/sp-sdk";
import { wagmiConfig } from '@/components/Providers';
import {
  Name
} from '@coinbase/onchainkit/identity';


const SelectPage = () => {
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [dappsId, setDappsId] = useState('');
  const [inviterAddress, setInviterAddress] = useState('');
  const router = useRouter();
  const { signMessageAsync } = useSignMessage();
  const chainId = useChainId();
  const { address, isConnected } = useAccount();
  const [inviterAttestationId, setInviterAttestationId] = useState('');
  const [inviteeAttestationId, setInviteeAttestationId] = useState('');
  const [hcaptchaToken, setHcaptchaToken] = useState<string | null>(null);
  const { disconnect } = useDisconnect();
  const { chains, switchChain } = useSwitchChain()
  const [showChainButtons, setShowChainButtons] = useState(false);
  const [inviterChainId, setInviterChainId] = useState('');
  const [inviteeChainId, setInviteeChainId] = useState('');

  async function queryAttestations(inviterAttestationId: string, inviteeAttestationId: string, inviterChainId: string, inviteeChainId: string) {
    const indexService = new IndexService("testnet");
  
    const inviterAttId = `onchain_evm_${inviterChainId}_${inviterAttestationId}`;
    const inviteeAttId = `onchain_evm_${inviteeChainId}_${inviteeAttestationId}`;

    console.log('inviterAttId:', inviterAttId);
    console.log('inviteeAttId:', inviteeAttId);

    const inviterRes = await indexService.queryAttestation(inviterAttId as string);
    console.log('inviterAttestation:', inviterRes?.data);

    const inviterValues = decodeAbiParameters(
      [
        { name: 'inviter', type: 'address' },
        { name: 'signature', type: 'bytes' },
        { name: 'dappsId', type: 'uint256' },
        { name: 'originalChain', type: 'uint256' },
        { name: 'targetChain', type: 'uint256' },
      ],
      inviterRes?.data as `0x${string}`,
    )

    const inviteeRes = await indexService.queryAttestation(inviteeAttId as string);
    console.log('inviteeAttestation:', inviteeRes?.data);

    const inviteeValues = decodeAbiParameters(
      [
        { name: 'invitee', type: 'address' },
        { name: 'inviter', type: 'address' },
        { name: 'dappsId', type: 'uint256' },
        { name: 'signature', type: 'bytes' },
        { name: 'captchaSignature', type: 'bytes' },
        { name: 'captchaSigner', type: 'address' },
        { name: 'sourceChainSelector', type: 'uint256' },
        { name: 'targetChainSelector', type: 'uint256' }
      ],
      inviteeRes?.data as `0x${string}`,
    )

    console.log('inviterValues:', inviterValues);
    console.log("inviter:", inviterValues[0]);

    console.log('inviteeValues:', inviteeValues);
    console.log("invitee:", inviteeValues[1]);

    if (inviterValues[0] === inviteeValues[1]) {
      return {
        success: true
      }
    }
    else {
      return {
        success: false
      }
    }
  }
  
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
      console.log('ECDSA signature:', signature);
      toast.success('ECDSA signature generated successfully');

      const createInvitationTx = await writeContract(wagmiConfig, {
        abi: ShowtieABI,
        address: '0xc6a3C5ce873481F0EB6Bb2b172cDD6e27e8aCff1',
        functionName: 'createInvitation',
        args: [
          BigInt('10344971235874465080'),
          '0xEff4F710b63DfF778052aa093FD34584Da5a4589',
          BigInt(dappsId),
          signature,
        ],
      });

      console.log(createInvitationTx, 'createInvitationTx');

      toast.success(
        `https://base-sepolia.blockscout.com/tx/${createInvitationTx}/`
      );

      toast.success(``)
      
    } catch (error) {
      toast.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    }
  };

  const handleInviteeSubmit  = async (event: React.FormEvent) => {
    event.preventDefault();

    try {
      console.log('hcaptchaToken:', hcaptchaToken);
      
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

      if (!inviterAddress) {
        toast.error('Please Enter Inviter Address');
        return;
      }

      // Create packed message
      const packedCaptchaMessage = encodePacked(
        ['address', 'uint256'],
        [address as `0x${string}`, BigInt(dappsId)]
      );

      // Create message hash for ECDSA signature
      const captchaMessageHash = keccak256(packedCaptchaMessage);
      console.log('captchaMessageHash:', captchaMessageHash);
      console.log('process.env.WALLET_PRIVATE_KEY:', process.env.NEXT_PUBLIC_WALLET_PRIVATE_KEY);
      const account = privateKeyToAccount(process.env.NEXT_PUBLIC_WALLET_PRIVATE_KEY as `0x${string}`);
      console.log('account:', account);
      const captchaSignature = await signMessageAsync({
        account: account,
        message: { raw: captchaMessageHash }
      });
      console.log('captchaSignature:', captchaSignature);

      // Create packed message
      const inviteePackedMessage = encodePacked(
        ['address', 'uint256'],
        [inviterAddress as `0x${string}`, BigInt(dappsId)]
      );
      console.log('address:', address);
      // Create message hash for ECDSA signature
      const inviteeMessageHash = keccak256(inviteePackedMessage);
      console.log('inviteeMessageHash:', inviteeMessageHash);
      // Generate ECDSA signature
      const inviteeSignature = await signMessageAsync({
        account: address, 
        message: { raw: inviteeMessageHash }
      });
      console.log('inviteeSignature:', inviteeSignature);
      toast.success('ECDSA signature generated successfully');

      const approveInvitationTx = await writeContract(wagmiConfig, {
        abi: ShowtieABI,
        address: '0xc6a3C5ce873481F0EB6Bb2b172cDD6e27e8aCff1',
        functionName: 'approveInvitation',
        args: [
          BigInt(dappsId),
          inviterAddress as `0x${string}`,
          inviteeSignature,
          captchaSignature,
        ],
      });

      console.log(approveInvitationTx, 'approveInvitationTx');

      toast.success(
        `https://base-sepolia.blockscout.com/tx/${approveInvitationTx}/`
      );
      
    } catch (error) {
      toast.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    }
  };

  const handleDappsSubmit  = async (event: React.FormEvent) => {
    event.preventDefault();

    try {
      if (!inviterAttestationId) {
        toast.error('Please Enter Inviter Attestation Id');
        return;
      }

      if (!inviteeAttestationId) {
        toast.error('Please Enter Invitee Attestation Id');
        return;
      }

      if (!inviterChainId) {
        toast.error('Please Enter Inviter Chain Id');
        return;
      }

      if (!inviteeChainId) {
        toast.error('Please Enter Invitee Chain Id');
        return;
      }


      const res = await queryAttestations(inviterAttestationId, inviteeAttestationId, inviterChainId, inviteeChainId);

      console.log('res:', res);
      console.log('res.success:', res.success);

      if (res.success) {
        toast.success('Send Reward Successfully!!!');

        // mint reward
        const transaction = await writeContract(wagmiConfig, {
          abi: ERC20ABI,
          address: '0x7BD72b6D118F763832185744Ee054A550B6eb4cf',
          functionName: 'mint',
          args: ['0xa97999f603247570fa688f40aAeAef7A90676254', BigInt(10)],
        });
        
        console.log('transaction:', transaction);
        toast.success(
          `https://base-sepolia.blockscout.com/${transaction}/`
        );
      }
      else {
        toast.error('Send Reward Failed');
      }
      
    } catch (error) {
      toast.error(`Error: ${error instanceof Error ? error.message : String(error)}`);
    }
  };

  const getChainSelectorIdByChainId = (
    chainId: string
  ): bigint | undefined => {
    const chainData = data.find((item) => item.chainId === parseInt(chainId));
    console.log('chainData', chainData);
    return chainData ? BigInt(chainData.chainSelectorId) : undefined;
  };


  const handleSelect = (option: string) => {
    setSelectedOption(option);
    setTimeout(() => {
      setShowForm(true);
    }, 100);
  };

  const handleDisconnect = () => {
    disconnect();
    router.push('/');
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
              placeholder="DApps Id"
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
              placeholder="DApps Id"
              className="bg-white/10 border-white/20 text-white"
              value={dappsId}
              onChange={(e) => setDappsId(e.target.value)}
              required
            />
            <Input
              placeholder="Inviter Address"
              className="bg-white/10 border-white/20 text-white"
              value={inviterAddress}
              onChange={(e) => setInviterAddress(e.target.value)}
              required
            />
            <div className="flex justify-center">
              {process.env.NEXT_PUBLIC_HCAPTCHA_SITE_KEY && (
                <HCaptcha
                    sitekey={process.env.NEXT_PUBLIC_HCAPTCHA_SITE_KEY}
                    onVerify={(token) => setHcaptchaToken(token)}
                    theme="dark"
                    size="compact"
                  />
              )}
            </div>
            <Button
              type="submit"
              className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white p-6 rounded-xl text-lg"
            >
              Approve Invitation
            </Button>
          </form>
        ) : selectedOption === 'dapps' ? (
          // dapps form
          <form onSubmit={handleDappsSubmit} className="space-y-4">
            <h2 className="text-xl font-bold text-white mb-4">
              Enter Dapps Information
            </h2>
            <Input
              placeholder="Inviter Attestation Id"
              className="bg-white/10 border-white/20 text-white"
              value={inviterAttestationId}
              onChange={(e) => setInviterAttestationId(e.target.value)}
              required
            />
            <Input
              placeholder="Inviter Chain Id"
              className="bg-white/10 border-white/20 text-white"
              value={inviterChainId}
              onChange={(e) => setInviterChainId(e.target.value)}
              required
            />
            <Input
              placeholder="Invitee Attestation Id"
              className="bg-white/10 border-white/20 text-white"
              value={inviteeAttestationId}
              onChange={(e) => setInviteeAttestationId(e.target.value)}
              required
            />
            <Input
              placeholder="Invitee Chain Id"
              className="bg-white/10 border-white/20 text-white"
              value={inviteeChainId}
              onChange={(e) => setInviteeChainId(e.target.value)}
              required
            />
            <Button
              type="submit"
              className="w-full bg-gradient-to-r from-green-500 to-teal-500 text-white p-6 rounded-xl text-lg"
            >
              Verify & Send Reward
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
              <div className="mb-4"></div>
            </div>
          )}

          {renderForm()}

          <div className="flex justify-center space-x-2">
            <button
              onClick={() => setShowChainButtons(!showChainButtons)}
              className="px-4 py-2 bg-gray-500 text-white font-semibold rounded-lg shadow-md hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-400 focus:ring-opacity-75"
            >
              ▼
            </button>
            {showChainButtons && (
              <>
                {chains.map((chain) => {
                  let bgColor;
                  switch (chain.name.toLowerCase()) {
                    case 'base sepolia':
                      bgColor = 'bg-blue-500';
                      break;
                    case 'sepolia':
                      bgColor = 'bg-gray-500';
                      break;
                    case 'alfajores':
                      bgColor = 'bg-yellow-500';
                      break;
                    case 'scroll sepolia':
                      bgColor = 'bg-orange-500';
                      break;
                    default:
                      bgColor = 'bg-blue-500';
                  }
                  return (
                    <button
                      key={chain.id}
                      onClick={async () => {
                        try {
                          console.log('chainId:', chain.id);
                          await switchChain({ chainId: chain.id });
                          console.log(`Switched to chain: ${chain.name}`);
                        } catch (error) {
                          console.error(`Failed to switch chain: ${error instanceof Error ? error.message : String(error)}`);
                        }
                      }}
                      className={`flex-1 px-4 py-2 ${bgColor} text-white font-semibold rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-opacity-75`}
                    >
                      {chain.name}
                    </button>
                  );
                })}
              </>
            )}
          </div>

          {address && (
            <>
              <Name 
                address={address} 
                className="w-full bg-gradient-to-r from-purple-500 via-pink-500 to-red-500 text-white font-bold py-4 rounded-full text-lg relative overflow-hidden group text-center flex justify-center mt-6"
            /> 
              <Button 
                onClick={handleDisconnect}
                className="w-full bg-gradient-to-r from-purple-500 via-pink-500 to-red-500 text-white font-bold py-4 rounded-full text-lg relative overflow-hidden group text-center flex justify-center mt-6"
              >
                Logout
              </Button>
            </>
          )}
        </div>
      </motion.div>
    </div>
  );
}

export default SelectPage;