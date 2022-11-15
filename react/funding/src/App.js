import Web3 from 'web3';
import { useEffect, useState } from 'react';
import funder from "./contracts/funder.json";
import React from 'react'
import './App.css';

function App() {
  const [web3API, setweb3API] = useState({
    web3: null,
    myContract: null
  })
  const [account, setAccount] = useState(null)
  const [balance, setBalance] = useState(null)
  const [accountBalance, setAccountBalance] = useState(null)
  const [True, setTrue] = useState(false)


  const loadProvider = () =>
    new Promise((resolve, reject) => {
      window.addEventListener("load", async () => {
        let provider = null;
        if (window.ethereum) {

          const web3 = new Web3(window.ethereum);
          try {
            await window.ethereum.request({ method: "eth_requestAccounts" });
            resolve(web3);
          }
          catch {
            console.error("user not allowed with ethereum");
          }
        }
        else if (window.web3) {
          const web3 = window.web3;
          try {
            provider = await window.web3.currentProvider();
            resolve(web3);
          } catch {
            console.error("user not allowed");
          }
        }
        else if (!process.env.production) {
          provider = await new Web3.provider.HttpProvider("http://localhost:7545")
          const web3 = new Web3(provider);
          resolve(web3);
        }
      })
    })

  useEffect(() => {

    const createInstance = async () => {
      const web3 = await loadProvider();

      try {
        const networkId = await web3.eth.net.getId();
        const deployedNetwork = funder.networks[networkId];
        const instance = new web3.eth.Contract(funder.abi, deployedNetwork && deployedNetwork.address);
        setweb3API({
          web3,
          myContract: instance
        })
      } catch (error) {
        alert("failed to load web3 or contract")
        console.error(error)
      }
    }
    createInstance();

  }, [])


  useEffect(() => {
    const getAccount = async () => {
      const account = await web3API.web3.eth.getAccounts();
      setAccount(account[0]);
    }
    web3API && getAccount();
  }, [web3API])

  useEffect(()=>{
    const getBalance= async()=>{
      const balance= await web3API.web3.eth.getBalance("0xc0c20Dd50534CB057Ed9F65d4d77304b30c8485d")

      setBalance(web3API.web3.utils.fromWei(balance,"ether"));
    }
    web3API&& getBalance();
  },[web3API,True])


  useEffect(()=>{
    const getAccountBalance= async()=>{
      const accountBalance= await web3API.web3.eth.getBalance(account);

      setAccountBalance(web3API.web3.utils.fromWei(accountBalance,"ether"))
    }
    web3API&& getAccountBalance();
  },[account,True])


  const transferFunds=async()=>{
    await web3API.myContract.methods.fundTransfer().send({
      from:account,
      value:web3API.web3.utils.toWei("1","ether")
    },function(err,res){});
    setTrue(!True)
  }


  const withdrawFund=async()=>{
    console.log("1")
    await web3API.myContract.methods.withdraw().send({from:account});
    console.log("2")
    setTrue(!True)
  }


  return (
    <>
    <div className="container my-3" style={{ width: "35rem" }}>
      <div className="card text-center">
        <div className="card-header mb-4">Funding</div>
        <h5 className="card-title">Contract Balance:{balance}</h5>
        <p className="card-text">Account Balance:{accountBalance}</p>
        <div className="d-flex justify-content-center my-4" >
          &nbsp;
          <button type="submit" className="btn btn-success" onClick={transferFunds}>Transfer</button>
          &nbsp;
          <button type="button" className="btn btn-primary"onClick={withdrawFund}>Withdraw</button>
        </div>
        <div className="card-footer text-muted mt-4">Account Number:{account ? account : "no account found"}</div>
      </div>
    </div>
  </>
  );
}

export default App;
