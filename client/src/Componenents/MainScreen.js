import React, { useState } from "react";
import { Button, Form, FormGroup, Label, Input, FormText } from "reactstrap";

const MainScreen = (props) => {
  let owner;
  const handleSubmit = async (e) => {
    e.preventDefault();
    owner = props.contract.methods.getOwner().call();
    const contract = props.contract;
    const res = await contract.methods.mintNFT(1).send({ from: props.account });
    console.log(res);
    console.log(owner);
  };
  return (
    <div className="container">
      <Form onSubmit={(e) => handleSubmit(e)}>
        <FormGroup>
          <Input placeholder="name" />
        </FormGroup>
        <FormGroup>
          <Input placeholder="description" />
        </FormGroup>
        <FormGroup>
          <Input type="file" name="file" />
          <FormText color="muted">NFT image</FormText>
        </FormGroup>

        <Button color="primary">Mint</Button>
      </Form>
      <div>{owner}</div>
    </div>
  );
};
export default MainScreen;
