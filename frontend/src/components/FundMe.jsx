import { useState, useEffect, use } from "react";
import { ethers } from "ethers";
import { abi } from "../constants/abi";
import { contractAddress } from "../constants/contractAddress";

export default function FundMe() {
  const [amount, setAmount] = useState("");
  const [status, setStatus] = useState("Please install a wallet to connect");
  const [isConnected, setIsConnected] = useState(false);
  const [balance, setBalance] = useState("0");

  // 🔹 Connect Wallet
  async function connectWallet() {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      if (accounts.length > 0) {
        setIsConnected(true);
        setStatus(`${accounts.length} account connected`);
      }
    } else {
      setStatus("Please install MetaMask.");
    }
  }

  // 🔹 Fund Contract
  async function fund() {
    try {
      if (!window.ethereum) return setStatus("No MetaMask found!");
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);

      const tx = await contract.fund({
        value: ethers.parseEther(amount),
      });

      setStatus("Transaction sent... Waiting...");
      await tx.wait();
      setStatus(`${amount} ETH Funded successfully!`);
      await getBalance();
    } catch (err) {
      console.error(err);
      setStatus("Transaction failed.");
    }
  }

  // 🔹 Withdraw Funds (Owner only)
  async function withdraw() {
    try {
      if (!window.ethereum) return setStatus("No MetaMask found!");
      const provider = new ethers.BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);

      const balanceWei = await provider.getBalance(contractAddress);
      const balanceEth = ethers.formatEther(balanceWei);

      const tx = await contract.withdraw();
      setStatus("Withdraw transaction sent... Waiting...");
      await tx.wait();
      setStatus(`Withdrawn a total of ${balanceEth} ETH from the contract successfully!`);
      await getBalance();
    } catch (err) {
      console.error(err);
      setStatus("Only owner can withdraw, transaction failed.");
    }
  }

  // 🔹 Get Contract Balance
  async function getBalance() {
    try {
      if (!window.ethereum) return setStatus("No MetaMask found!");
      const provider = new ethers.BrowserProvider(window.ethereum);

      const balanceWei = await provider.getBalance(contractAddress);
      const balanceEth = ethers.formatEther(balanceWei);
      setBalance(balanceEth);
      //setStatus(`Balance fetched: ${balanceEth} ETH`);
    } catch (err) {
      console.error(err);
      setStatus("Failed to fetch balance.");
    }
  }

  useEffect(() => {
    async function checkConnection() {
      if (!window.ethereum) return setStatus("No MetaMask found!");
      const accounts = await window.ethereum.request({ method: "eth_accounts" });
      if (accounts.length > 0) {
        setIsConnected(true);
        setStatus(`${accounts.length} account connected`);
        await getBalance();
      } else {
        setStatus("Please install a wallet to connect.");
      }
    }
    checkConnection();
  }, []);

  return (
    <div style={{ padding: "10px" }} className="min-h-screen bg-gradient-to-br from-gray-800 via-teal-900 to-cyan-900 relative">
      <div className="absolute top-5 flex right-5 gap-4">

        <button
          onClick={withdraw}
          className="bg-gray-900 text-white border-5 border-gray-600 px-7 py-2 rounded-3xl hover:shadow-xl shadow-md hover:bg-gray-700 transition cursor-pointer"
        >Withdraw</button>
        <button
          onClick={connectWallet}
          className=" bg-gray-900 text-white border-5 border-gray-600 px-7 py-2 rounded-3xl hover:shadow-xl shadow-md hover:bg-gray-700 transition cursor-pointer"
        >
          {isConnected ? "Connected" : "Connect"}
        </button>



      </div>

      <div className="flex flex-col items-center justify-center h-screen gap-4 ">
        <h2 className="text-4xl font-bold text-white">Fund Me Project</h2>
        <div className="flex items-center gap-4">
          <input
            type="text"
            placeholder="Enter amount in ETH"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className=" p-2 bg-white  w-64 text-center"
          />
          <button onClick={fund}
            className="bg-gray-900 text-white px-7 py-2 rounded-3xl hover:bg-gray-700 transition cursor-pointer"
          >Fund</button>
        </div>


        <p className="text-white text-xl font-semibold py-5">Contract Balance: {balance} ETH</p>



        <p className="bg-white/30 bg-opacity-20 text-white px-4 py-2 rounded text-center translate-y-8">
          {status}
        </p>




      </div>


    </div>
  );
}
