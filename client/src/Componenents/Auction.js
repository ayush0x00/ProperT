import React, { useState } from "react";
import { Button, Form, FormGroup, Label, Input, FormText } from "reactstrap";

const Auction = (props) => {
  let owner;
  const handleAuction = async (e) => {
    e.preventDefault();
    const contract = props.contract;
    const start = e.target[0].value;
    const end = e.target[1].value;
    const res = await contract.methods
      .createAuction(start, end)
      .send({ from: props.account });
    console.log(res);
  };

  const listForAuction = async (e) => {
    e.preventDefault();
    const id = e.target[0].value;
    const bid = e.target[1].value;

    const res = await props.contract.methods
      .listForAuction(id)
      .send({ from: props.account, value: bid });
    console.log(res);
  };
  const handleBid = async (e) => {
    e.preventDefault();
    const bal = await props.contract.methods.getBidders(1).call();
    console.log(bal);
    const id = e.target[0].value;
    const bid = e.target[1].value;

    const res = await props.contract.methods
      .Bid(id)
      .send({ from: props.account, value: bid });
    console.log(res);
  };

  const getResult = async (e) => {
    e.preventDefault();
    const bal = await props.contract.methods.getContractBalance().call();
    console.log(bal);
    const res = await props.contract.methods
      .getAuctionResult()
      .send({ from: props.account });
    console.log(res);
  };
  return (
    <>
      <div className="container">
        <Form onSubmit={(e) => handleAuction(e)}>
          <FormGroup>
            <Input placeholder="start block" />
          </FormGroup>
          <FormGroup>
            <Input placeholder="end block" />
          </FormGroup>

          <Button color="primary">Create Auction</Button>
        </Form>
      </div>
      <div className="container">
        <Form onSubmit={(e) => listForAuction(e)}>
          <FormGroup>
            <Input placeholder="NFT id" />
          </FormGroup>
          <FormGroup>
            <Input placeholder="Initial Bid" />
          </FormGroup>

          <Button color="primary">List NFT for auction</Button>
        </Form>
      </div>
      <div className="container">
        <Form onSubmit={(e) => handleBid(e)}>
          <FormGroup>
            <Input placeholder="NFT id" />
          </FormGroup>
          <FormGroup>
            <Input placeholder="Bid Amount" />
          </FormGroup>
          <Button color="primary">Place Bid</Button>
        </Form>
      </div>
      <Button color="success" onClick={getResult}>
        Get Result
      </Button>
    </>
  );
};
export default Auction;
