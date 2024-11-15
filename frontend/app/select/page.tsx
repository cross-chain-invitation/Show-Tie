'use client';

import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input" 
import { useState } from "react"
import { useRouter } from 'next/navigation';

export default function SelectPage() {
  const [selectedOption, setSelectedOption] = useState<string | null>(null)
  const [showForm, setShowForm] = useState(false)

  const handleSelect = (option: string) => {
    setSelectedOption(option)
    setTimeout(() => {
      setShowForm(true)
    }, 1000)
  }

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
            <h2 className="text-xl font-bold text-white mb-4">Enter Required Information</h2>
            <Input placeholder="dapps_id" className="bg-white/10 border-white/20 text-white" />
          </>
        ) : (
          // invitee form
          <>
            <h2 className="text-xl font-bold text-white mb-4">Enter Required Information</h2>
            <Input placeholder="dapps_id" className="bg-white/10 border-white/20 text-white" />
            <Input placeholder="inviter_address" className="bg-white/10 border-white/20 text-white" />
          </>
        )}
        
        <Button className="w-full bg-gradient-to-r from-green-500 to-emerald-500 text-white p-6 rounded-xl text-lg mt-4">
          Accept
        </Button>
      </motion.div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-black p-4">
      <motion.div 
        className="w-full max-w-md"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="bg-white/10 backdrop-blur-3xl rounded-3xl shadow-2xl border border-white/20 p-8 space-y-6">
          <h1 className="text-3xl font-bold text-center text-white mb-8">
            {!selectedOption ? 
              'Choose Your Role' : 
              'You have selected ' + selectedOption
            }
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
  )
}
