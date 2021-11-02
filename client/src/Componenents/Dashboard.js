import React, { useState, useEffect } from "react";
import Main from "../build/Main.json";
import Web3 from "web3";
import MainScreen from "./MainScreen";
import Auction from "./Auction";

const Dashboard = () => {
  const [account, setAccount] = useState();
  const [contract, setContract] = useState();
  const [totalNFT, updateNFT] = useState(0);
  useEffect(() => {
    async function fetchData() {
      await loadWeb3();
      await loadData();
    }
    fetchData();
  }, []);

  const loadWeb3 = async () => {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    } else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
    } else {
      window.alert("Install metamask to continue");
    }
  };

  const loadData = async () => {
    const web3 = window.web3;
    const accounts = await web3.eth.getAccounts();
    setAccount(accounts[0]);
    const netId = await web3.eth.net.getId();
    const networkData = Main.networks[netId];
    const abi = Main.abi;
    const address = networkData.address;
    const myContract = await new web3.eth.Contract(abi, address);
    setContract(myContract);
    console.log(myContract);
  };
  return (
    <div>
      <div>
        {`Connected with account ${account}`}
        <MainScreen contract={contract} account={account} />
        <Auction contract={contract} account={account} />
      </div>
    </div>
  );
};

export default Dashboard;
